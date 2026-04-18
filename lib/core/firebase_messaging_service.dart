import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../features/notifications/data/notifications_service.dart';
import 'local_alert_service.dart';
import 'notification_navigation_service.dart';
import 'secure_storage.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService I = FirebaseMessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _ready = false;

  String _maskToken(String? token) {
    final value = (token ?? '').trim();
    if (value.isEmpty) return '(empty)';
    if (value.length <= 10) return '$value...';
    return '${value.substring(0, 10)}...';
  }

  String _messageDedupeKey(RemoteMessage message) {
    final data = message.data;
    final type = (data['type'] ?? '').toString().trim();
    final id = (data['id'] ??
            data['order_id'] ??
            data['other_request_id'] ??
            data['conversationId'] ??
            data['conversation_id'] ??
            '')
        .toString()
        .trim();

    final title = (message.notification?.title ?? '').trim();
    final body = (message.notification?.body ?? '').trim();

    return 'fcm|$type|$id|$title|$body';
  }

  Future<void> _registerTokenForRole({
    required String token,
    required String role,
  }) async {
    await NotificationsService().registerDevice(
      deviceToken: token,
      role: role,
      platform: Platform.isAndroid ? 'android' : 'unknown',
    );
  }

  Future<void> _registerTokenForActiveRoles(String token) async {
    final adminToken = await AppStorage.I.getAdminToken();
    final clientToken = await AppStorage.I.getClientToken();

    if (adminToken != null && adminToken.isNotEmpty) {
      try {
        await _registerTokenForRole(token: token, role: 'admin');
        log('FCM token registered for admin');
      } catch (e) {
        log('FCM admin registerDevice failed: $e');
      }
    }

    if (clientToken != null && clientToken.isNotEmpty) {
      try {
        await _registerTokenForRole(token: token, role: 'client');
        log('FCM token registered for client');
      } catch (e) {
        log('FCM client registerDevice failed: $e');
      }
    }
  }


  Map<String, dynamic> _messagePayload(RemoteMessage message) {
    final data = <String, dynamic>{...message.data};

    data['title'] = (message.notification?.title ?? data['title'] ?? '').toString();
    data['body'] = (message.notification?.body ?? data['body'] ?? '').toString();

    if (!data.containsKey('order_id') && data['id'] != null) {
      final type = (data['type'] ?? '').toString().trim();
      if (type.contains('order')) {
        data['order_id'] = data['id'];
      }
    }

    return data;
  }

  Future<void> _openMessage(RemoteMessage message) async {
    final payload = _messagePayload(message);
    await NotificationNavigationService.I.openOrQueueGlobal(payload);
  }

  Future<void> init() async {
    if (_ready) return;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        await LocalAlertService.I.show(
          id: notification.hashCode,
          title: notification.title ?? 'إشعار جديد',
          body: notification.body ?? '',
          dedupeKey: _messageDedupeKey(message),
          payloadData: _messagePayload(message),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      log('FCM onMessageOpenedApp: ${message.messageId}');
      await _openMessage(message);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      log('FCM getInitialMessage: ${initialMessage.messageId}');
      await _openMessage(initialMessage);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      log('FCM token refreshed: ${_maskToken(newToken)}');
      await _registerTokenForActiveRoles(newToken);
    });

    _ready = true;
  }

  Future<void> syncTokenToServer({required String role}) async {
    final normalizedRole = role.trim().toLowerCase();
    final token = await _messaging.getToken();
    log('FCM token sync [$normalizedRole]: ${_maskToken(token)}');

    if (token != null && token.isNotEmpty) {
      await _registerTokenForRole(
        token: token,
        role: normalizedRole,
      );
      log('FCM token registered successfully for $normalizedRole');
    } else {
      log('FCM token is null or empty');
    }
  }

  Future<String?> getToken() => _messaging.getToken();
}
