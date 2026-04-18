import 'dart:convert';

import '../../../core/api_client.dart';
import '../models/notification_item_model.dart';

class ClientNotificationsService {
  Map<String, dynamic> _parseDataJson(dynamic rawData) {
    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }

    if (rawData is String) {
      final text = rawData.trim();
      if (text.isEmpty) return <String, dynamic>{};

      try {
        final decoded = jsonDecode(text);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }

    return <String, dynamic>{};
  }

  Future<List<NotificationItemModel>> listNotifications() async {
    final res = await ApiClient.I.dio.get('/client/notifications');
    final data = res.data;

    if (data is! Map) {
      return <NotificationItemModel>[];
    }

    final root = Map<String, dynamic>.from(data);
    final raw = (root['notifications'] as List?) ?? const [];

    return raw.whereType<Map>().map((e) {
      final map = Map<String, dynamic>.from(e);
      return NotificationItemModel.fromMap({
        'id': int.tryParse('${map['id']}') ?? 0,
        'role': (map['role'] ?? '').toString(),
        'title': (map['title'] ?? '').toString(),
        'body': (map['body'] ?? '').toString(),
        'is_read': map['is_read'] == true ||
            '${map['is_read']}'.toLowerCase() == 'true',
        'created_at': (map['created_at'] ?? '').toString(),
        'data_json': _parseDataJson(map['data_json']),
      });
    }).toList();
  }

  Future<int> unreadCount() async {
    final rows = await listNotifications();
    return rows.where((e) => !e.isRead).length;
  }

  Future<Map<String, dynamic>> markRead({int? id, bool all = false}) async {
    final res = await ApiClient.I.dio.post(
      '/client/notifications/read',
      data: {
        if (id != null) 'id': id,
        'all': all,
      },
    );

    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    return {'ok': false, 'error': 'BAD_RESPONSE'};
  }
}
