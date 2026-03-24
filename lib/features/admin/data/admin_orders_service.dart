import 'package:drift/drift.dart';

import '../../../core/api_client.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/local_db/db.dart';

class AdminOrdersService {
  Map<String, dynamic> _normalizeOrder(Map raw) {
    return {
      'id': int.tryParse('${raw['id']}') ?? 0,
      'client_id': int.tryParse('${raw['client_id']}') ?? 0,
      'email': (raw['email'] ?? '').toString(),
      'phone': (raw['phone'] ?? '').toString(),
      'lat': double.tryParse('${raw['lat']}'),
      'lng': double.tryParse('${raw['lng']}'),
      'accuracy_m': double.tryParse('${raw['accuracy_m']}'),
      'status': (raw['status'] ?? '').toString(),
      'total_cents': int.tryParse('${raw['total_cents']}') ?? 0,
      'paid_cents': int.tryParse('${raw['paid_cents']}') ?? 0,
      'admin_note': raw['admin_note']?.toString(),
      'reject_reason': raw['reject_reason']?.toString(),
      'scheduled_at': raw['scheduled_at']?.toString(),
      'completed_at': raw['completed_at']?.toString(),
      'created_at': raw['created_at']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeItem(Map raw) {
    return {
      'machine_id': int.tryParse('${raw['machine_id']}') ?? 0,
      'machine_name': (raw['machine_name'] ?? '').toString(),
      'icon': (raw['icon'] ?? '🧵').toString(),
      'qty': int.tryParse('${raw['qty']}') ?? 0,
      'unit_price_cents': int.tryParse('${raw['unit_price_cents']}') ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> listOrders() async {
    try {
      final res = await ApiClient.I.dio.get('/admin/orders');
      final root = Map<String, dynamic>.from(res.data as Map);
      final raw = (root['orders'] as List?) ?? const [];
      final list = raw.whereType<Map>().map(_normalizeOrder).toList();

      final rows = list.map((o) {
        return CachedAdminOrdersCompanion(
          id: Value(o['id'] as int),
          clientId: Value(o['client_id'] as int),
          email: Value((o['email'] ?? '').toString()),
          phone: Value((o['phone'] ?? '').toString()),
          lat: Value(o['lat'] as double?),
          lng: Value(o['lng'] as double?),
          accuracyM: Value(o['accuracy_m'] as double?),
          status: Value((o['status'] ?? '').toString()),
          totalCents: Value(o['total_cents'] as int),
          paidCents: Value(o['paid_cents'] as int),
          adminNote: Value(o['admin_note']?.toString()),
          rejectReason: Value(o['reject_reason']?.toString()),
          scheduledAt: Value(o['scheduled_at']?.toString()),
          completedAt: Value(o['completed_at']?.toString()),
          createdAt: Value(o['created_at']?.toString()),
          cachedAt: Value(DateTime.now()),
        );
      }).toList();

      await DB.I.database.replaceAdminOrders(rows);
      return list;
    } catch (_) {
      final cached = await DB.I.database.getAdminOrders();
      return cached.map((o) {
        return {
          'id': o.id,
          'client_id': o.clientId,
          'email': o.email,
          'phone': o.phone,
          'lat': o.lat,
          'lng': o.lng,
          'accuracy_m': o.accuracyM,
          'status': o.status,
          'total_cents': o.totalCents,
          'paid_cents': o.paidCents,
          'admin_note': o.adminNote,
          'reject_reason': o.rejectReason,
          'scheduled_at': o.scheduledAt,
          'completed_at': o.completedAt,
          'created_at': o.createdAt,
        };
      }).toList();
    }
  }

  Future<Map<String, dynamic>> getOrder(int id) async {
    final res = await ApiClient.I.dio.get('/admin/orders/$id');
    final root = Map<String, dynamic>.from(res.data as Map);
    return {
      'ok': root['ok'] == true,
      'order': root['order'] is Map ? _normalizeOrder(root['order'] as Map) : null,
      'items': ((root['items'] as List?) ?? const [])
          .whereType<Map>()
          .map(_normalizeItem)
          .toList(),
      'error': root['error'],
    };
  }

  Future<Map<String, dynamic>> getOrderChat(int id) async {
    final res = await ApiClient.I.dio.get('/admin/orders/$id/chat');
    final root = Map<String, dynamic>.from(res.data as Map);

    final conv = root['conversation'];
    return {
      'ok': root['ok'] == true,
      'conversation': conv is Map
          ? {
              'id': int.tryParse('${conv['id']}') ?? 0,
              'order_id': conv['order_id'] == null
                  ? null
                  : int.tryParse('${conv['order_id']}'),
              'client_id': conv['client_id'] == null
                  ? null
                  : int.tryParse('${conv['client_id']}'),
              'created_at': conv['created_at']?.toString(),
            }
          : null,
      'error': root['error'],
    };
  }

  Future<Map<String, dynamic>> acceptOrder(int id, {String? adminNote}) async {
    final res = await ApiClient.I.dio.post(
      '/admin/orders/$id/accept',
      data: {
        if ((adminNote ?? '').trim().isNotEmpty)
          'admin_note': adminNote!.trim(),
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> rejectOrder(
    int id, {
    required String reason,
    String? adminNote,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/orders/$id/reject',
      data: {
        'reason': reason.trim(),
        if ((adminNote ?? '').trim().isNotEmpty)
          'admin_note': adminNote!.trim(),
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> scheduleOrder(
    int id, {
    required String scheduledAtIso,
    String? adminNote,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/orders/$id/schedule',
      data: {
        'scheduled_at': scheduledAtIso,
        if ((adminNote ?? '').trim().isNotEmpty)
          'admin_note': adminNote!.trim(),
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> completeOrder(
    int id, {
    String? adminNote,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/orders/$id/complete',
      data: {
        if ((adminNote ?? '').trim().isNotEmpty)
          'admin_note': adminNote!.trim(),
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }
}
