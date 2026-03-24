import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/api_client.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/local_db/db.dart';

class ClientOrdersService {
  Future<List<Map<String, dynamic>>> listMachines() async {
    final res = await ApiClient.I.dio.get('/machines');
    final data = res.data;
    if (data is! Map) return <Map<String, dynamic>>[];

    final root = Map<String, dynamic>.from(data);
    final raw = (root['machines'] as List?) ?? const [];

    return raw.whereType<Map>().map((e) {
      final map = Map<String, dynamic>.from(e);
      return {
        'id': int.tryParse('${map['id']}') ?? 0,
        'name': (map['name'] ?? '').toString(),
        'icon': (map['icon'] ?? '🧵').toString(),
        'price_cents': int.tryParse('${map['price_cents']}') ?? 0,
        'active':
            map['active'] == true ||
            '${map['active']}'.toLowerCase() == 'true',
        'sort_order': int.tryParse('${map['sort_order']}') ?? 0,
      };
    }).toList();
  }

  Future<Map<String, dynamic>> createOrder({
    required String phone,
    required double? lat,
    required double? lng,
    required double? accuracyM,
    required List<Map<String, dynamic>> items,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/client/orders',
      data: {
        'phone': phone,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (accuracyM != null) 'accuracy_m': accuracyM,
        'items': items,
      },
    );

    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    return {'ok': false, 'error': 'BAD_RESPONSE'};
  }

  Future<List<Map<String, dynamic>>> listMyOrders() async {
    try {
      final res = await ApiClient.I.dio.get('/client/orders');
      final data = res.data;
      if (data is! Map) {
        throw Exception('BAD_RESPONSE');
      }

      final root = Map<String, dynamic>.from(data);
      final raw = (root['orders'] as List?) ?? const [];

      final list = raw.whereType<Map>().map((e) {
        final map = Map<String, dynamic>.from(e);
        return {
          'id': int.tryParse('${map['id']}') ?? 0,
          'status': (map['status'] ?? '').toString(),
          'total_cents': int.tryParse('${map['total_cents']}') ?? 0,
          'paid_cents': int.tryParse('${map['paid_cents']}') ?? 0,
          'admin_note': (map['admin_note'] ?? '').toString(),
          'reject_reason': (map['reject_reason'] ?? '').toString(),
          'scheduled_at': (map['scheduled_at'] ?? '').toString(),
          'completed_at': (map['completed_at'] ?? '').toString(),
          'created_at': (map['created_at'] ?? '').toString(),
        };
      }).toList();

      final rows = list.map((o) {
        return CachedClientOrdersCompanion(
          id: Value(o['id'] as int),
          status: Value((o['status'] ?? '').toString()),
          totalCents: Value(o['total_cents'] as int),
          paidCents: Value(o['paid_cents'] as int),
          adminNote: Value((o['admin_note'] ?? '').toString()),
          rejectReason: Value((o['reject_reason'] ?? '').toString()),
          scheduledAt: Value((o['scheduled_at'] ?? '').toString()),
          completedAt: Value((o['completed_at'] ?? '').toString()),
          createdAt: Value((o['created_at'] ?? '').toString()),
          cachedAt: Value(DateTime.now()),
        );
      }).toList();

      await DB.I.database.replaceClientOrders(rows);

      return list;
    } catch (_) {
      final cached = await DB.I.database.getClientOrders();

      return cached.map((o) {
        return {
          'id': o.id,
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

  Future<Map<String, dynamic>> getMyOrder(int orderId) async {
    try {
      final res = await ApiClient.I.dio.get('/client/orders/$orderId');
      final data = res.data;

      if (data is! Map) {
        throw Exception('BAD_RESPONSE');
      }

      final root = Map<String, dynamic>.from(data);
      final orderRaw = root['order'];
      final itemsRaw = (root['items'] as List?) ?? const [];

      final result = {
        'ok': root['ok'] == true,
        'order': orderRaw is Map
            ? {
                'id': int.tryParse('${orderRaw['id']}') ?? 0,
                'client_id': int.tryParse('${orderRaw['client_id']}') ?? 0,
                'phone': (orderRaw['phone'] ?? '').toString(),
                'lat': orderRaw['lat'],
                'lng': orderRaw['lng'],
                'accuracy_m': orderRaw['accuracy_m'],
                'status': (orderRaw['status'] ?? '').toString(),
                'total_cents': int.tryParse('${orderRaw['total_cents']}') ?? 0,
                'paid_cents': int.tryParse('${orderRaw['paid_cents']}') ?? 0,
                'admin_note': (orderRaw['admin_note'] ?? '').toString(),
                'reject_reason': (orderRaw['reject_reason'] ?? '').toString(),
                'scheduled_at': (orderRaw['scheduled_at'] ?? '').toString(),
                'completed_at': (orderRaw['completed_at'] ?? '').toString(),
                'created_at': (orderRaw['created_at'] ?? '').toString(),
              }
            : null,
        'items': itemsRaw.whereType<Map>().map((e) {
          final map = Map<String, dynamic>.from(e);
          return {
            'machine_id': int.tryParse('${map['machine_id']}') ?? 0,
            'machine_name': (map['machine_name'] ?? '').toString(),
            'icon': (map['icon'] ?? '🧵').toString(),
            'qty': int.tryParse('${map['qty']}') ?? 0,
            'unit_price_cents':
                int.tryParse('${map['unit_price_cents']}') ?? 0,
          };
        }).toList(),
        'error': root['error'],
      };

      final order = result['order'];
      final items = result['items'];

      if (result['ok'] == true && order is Map<String, dynamic> && items is List) {
        await DB.I.database.saveClientOrderDetails(
          CachedClientOrderDetailsCompanion(
            orderId: Value(orderId),
            orderJson: Value(jsonEncode(order)),
            itemsJson: Value(jsonEncode(items)),
            cachedAt: Value(DateTime.now()),
          ),
        );
      }

      return result;
    } catch (_) {
      final cached = await DB.I.database.getClientOrderDetails(orderId);

      if (cached == null) {
        return {'ok': false, 'error': 'CACHE_EMPTY'};
      }

      return {
        'ok': true,
        'order': jsonDecode(cached.orderJson),
        'items': jsonDecode(cached.itemsJson),
        'error': null,
      };
    }
  }
}
