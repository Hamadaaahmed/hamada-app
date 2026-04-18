import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import 'notification_navigation_service.dart';

class LocalAlertService {
  LocalAlertService._();

  static final LocalAlertService I = LocalAlertService._();

  static const _channelId = 'hamada_alerts_v3';
  static const _channelName = 'Hamada Alerts V3';
  static const Duration _dedupeWindow = Duration(seconds: 4);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final Map<String, DateTime> _recentAlerts = <String, DateTime>{};

  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (payload == null || payload.trim().isEmpty) return;
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            await NotificationNavigationService.I.openOrQueueGlobal(
              Map<String, dynamic>.from(decoded),
            );
          }
        } catch (_) {}
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description:
                'Local alerts for orders, messages, and notifications',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );

    _ready = true;
  }

  void _cleanupRecentAlerts() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _recentAlerts.forEach((key, value) {
      if (now.difference(value) > _dedupeWindow) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _recentAlerts.remove(key);
    }
  }

  bool _shouldSkipDuplicate(String dedupeKey) {
    _cleanupRecentAlerts();

    final now = DateTime.now();
    final previous = _recentAlerts[dedupeKey];
    if (previous != null && now.difference(previous) <= _dedupeWindow) {
      return true;
    }

    _recentAlerts[dedupeKey] = now;
    return false;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? dedupeKey,
    Map<String, dynamic>? payloadData,
  }) async {
    await init();

    final key =
        (dedupeKey ?? '${title.trim()}|${body.trim()}').trim();

    if (key.isNotEmpty && _shouldSkipDuplicate(key)) {
      return;
    }

    FlutterRingtonePlayer().playNotification();

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      payload: payloadData == null ? null : jsonEncode(payloadData),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription:
              'Local alerts for orders, messages, and notifications',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          ticker: 'ticker',
        ),
      ),
    );
  }
}
