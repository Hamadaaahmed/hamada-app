import '../../../core/api_client.dart';

class ClientNotificationsService {
  Future<List<Map<String, dynamic>>> listNotifications() async {
    final res = await ApiClient.I.dio.get('/client/notifications');
    final data = res.data;

    if (data is! Map) {
      return <Map<String, dynamic>>[];
    }

    final root = Map<String, dynamic>.from(data);
    final raw = (root['notifications'] as List?) ?? const [];

    return raw.whereType<Map>().map((e) {
      final map = Map<String, dynamic>.from(e);
      final rawData = map['data_json'];

      return {
        'id': int.tryParse('${map['id']}') ?? 0,
        'role': (map['role'] ?? '').toString(),
        'title': (map['title'] ?? '').toString(),
        'body': (map['body'] ?? '').toString(),
        'is_read': map['is_read'] == true ||
            '${map['is_read']}'.toLowerCase() == 'true',
        'created_at': (map['created_at'] ?? '').toString(),
        'data_json': rawData is Map
            ? Map<String, dynamic>.from(rawData)
            : <String, dynamic>{},
      };
    }).toList();
  }

  Future<int> unreadCount() async {
    final rows = await listNotifications();
    return rows.where((e) => e['is_read'] != true).length;
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
