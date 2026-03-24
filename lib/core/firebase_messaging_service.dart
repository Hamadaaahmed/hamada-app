import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../features/notifications/data/notifications_service.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService I = FirebaseMessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'fcm_default_channel',
    'FCM Notifications',
    description: 'Notifications from Firebase Cloud Messaging',
    importance: Importance.max,
    playSound: true,
  );

  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _local.initialize(
      settings: initSettings,
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        await _local.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'fcm_default_channel',
              'FCM Notifications',
              channelDescription: 'Notifications from Firebase Cloud Messaging',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('FCM onMessageOpenedApp: ${message.messageId}');
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      log('FCM getInitialMessage: ${initialMessage.messageId}');
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      log('FCM token refreshed: $newToken');
      try {
        await NotificationsService().registerDevice(
          deviceToken: newToken,
          platform: Platform.isAndroid ? 'android' : 'unknown',
        );
        log('FCM refreshed token registered successfully');
      } catch (e) {
        log('FCM refreshed registerDevice failed: $e');
      }
    });

    _ready = true;
  }

  Future<void> syncTokenToServer() async {
    final token = await _messaging.getToken();
    log('FCM token sync: $token');

    if (token != null && token.isNotEmpty) {
      await NotificationsService().registerDevice(
        deviceToken: token,
        platform: Platform.isAndroid ? 'android' : 'unknown',
      );
      log('FCM token registered successfully');
    } else {
      log('FCM token is null or empty');
    }
  }

  Future<String?> getToken() => _messaging.getToken();
}
