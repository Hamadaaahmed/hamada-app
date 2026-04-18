import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../../core/api_client.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/local_db/db.dart';
import '../../other_requests/models/other_request_model.dart';
import '../../orders/models/order_model.dart';
import '../../orders/models/order_item_model.dart';

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

  Future<Map<String, dynamic>> createMachineRequest({
    required String machineName,
    required String faultDescription,
    required List<String> referenceImagePaths,
    required List<String> replacementImagePaths,
    required double? lat,
    required double? lng,
    required double? accuracyM,
  }) async {
    final formMap = <String, dynamic>{
      'machine_name': machineName,
      'fault_description': faultDescription,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
    };

    if (referenceImagePaths.isNotEmpty) {
      formMap['reference_image'] = await Future.wait(
        referenceImagePaths.map(MultipartFile.fromFile),
      );
    }

    if (replacementImagePaths.isNotEmpty) {
      formMap['replacement_image'] = await Future.wait(
        replacementImagePaths.map(MultipartFile.fromFile),
      );
    }

    final res = await ApiClient.I.dio.post(
      '/client/machine-requests',
      data: FormData.fromMap(formMap),
      options: Options(contentType: 'multipart/form-data'),
    );

    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    return {'ok': false, 'error': 'BAD_RESPONSE'};
  }

  Future<Map<String, dynamic>> createSparePartRequest({
    required String machineName,
    required String faultDescription,
    required List<String> referenceImagePaths,
    required double? lat,
    required double? lng,
    required double? accuracyM,
  }) async {
    final formMap = <String, dynamic>{
      'machine_name': machineName,
      'fault_description': faultDescription,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (accuracyM != null) 'accuracy_m': accuracyM,
    };

    if (referenceImagePaths.isNotEmpty) {
      formMap['reference_image'] = await Future.wait(
        referenceImagePaths.map(MultipartFile.fromFile),
      );
    }

    final res = await ApiClient.I.dio.post(
      '/client/spare-part-requests',
      data: FormData.fromMap(formMap),
      options: Options(contentType: 'multipart/form-data'),
    );

    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    return {'ok': false, 'error': 'BAD_RESPONSE'};
  }


  Future<List<OrderModel>> listMyOrderModels() async {
    try {
      final res = await ApiClient.I.dio.get('/client/orders');
      final data = res.data;
      if (data is! Map) {
        throw Exception('BAD_RESPONSE');
      }

      final root = Map<String, dynamic>.from(data);
      final raw = (root['orders'] as List?) ?? const [];

      final list = raw
          .whereType<Map>()
          .map((e) => OrderModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      final rows = list.map((o) {
        return CachedClientOrdersCompanion(
          id: Value(o.id),
          status: Value(o.status),
          totalCents: Value(o.totalCents),
          paidCents: Value(o.paidCents),
          adminNote: Value(o.adminNote),
          rejectReason: Value(o.rejectReason),
          scheduledAt: Value(o.scheduledAt),
          completedAt: Value(o.completedAt),
          createdAt: Value(o.createdAt),
          cachedAt: Value(DateTime.now()),
        );
      }).toList();

      await DB.I.database.replaceClientOrders(rows);
      return list;
    } catch (_) {
      final cached = await DB.I.database.getClientOrders();

      return cached.map((o) {
        return OrderModel(
          id: o.id,
          clientId: 0,
          phone: '',
          lat: null,
          lng: null,
          accuracyM: null,
          status: o.status,
          totalCents: o.totalCents,
          paidCents: o.paidCents,
          adminNote: o.adminNote,
          rejectReason: o.rejectReason,
          scheduledAt: o.scheduledAt,
          completedAt: o.completedAt,
          createdAt: o.createdAt,
        );
      }).toList();
    }
  }

  Future<List<Map<String, dynamic>>> listMyOrders() async {
    final rows = await listMyOrderModels();
    return rows.map((e) => e.toMap()).toList();
  }

  Future<List<OtherRequestModel>> listMyOtherRequestModels() async {
    final res = await ApiClient.I.dio.get('/client/other-requests');
    final data = res.data;
    if (data is! Map) {
      throw Exception('BAD_RESPONSE');
    }

    final root = Map<String, dynamic>.from(data);
    final raw = (root['requests'] as List?) ?? const [];

    return raw
        .whereType<Map>()
        .map((e) => OtherRequestModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<Map<String, dynamic>>> listMyOtherRequests() async {
    final rows = await listMyOtherRequestModels();
    return rows.map((e) => e.toMap()).toList();
  }

  Future<Map<String, dynamic>> acceptOtherRequestQuote(int requestId) async {
    final res = await ApiClient.I.dio.post(
      '/client/other-requests/$requestId/accept-quote',
    );
    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    return {'ok': false, 'error': 'BAD_RESPONSE'};
  }

  Future<Map<String, dynamic>> rejectOtherRequestQuote(int requestId) async {
    final res = await ApiClient.I.dio.post(
      '/client/other-requests/$requestId/reject-quote',
      data: {'reason': 'رفض العميل السعر'},
    );
    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    return {'ok': false, 'error': 'BAD_RESPONSE'};
  }

  Future<OtherRequestModel?> getMyOtherRequestModel(int requestId) async {
    final res = await ApiClient.I.dio.get('/client/other-requests/$requestId');
    final data = res.data;
    if (data is! Map) {
      throw Exception('BAD_RESPONSE');
    }

    final root = Map<String, dynamic>.from(data);
    final raw = root['request'];
    if (root['ok'] != true || raw is! Map) return null;

    return OtherRequestModel.fromMap(Map<String, dynamic>.from(raw));
  }

  Future<Map<String, dynamic>> getMyOtherRequest(int requestId) async {
    final res = await ApiClient.I.dio.get('/client/other-requests/$requestId');
    final data = res.data;
    if (data is! Map) {
      throw Exception('BAD_RESPONSE');
    }

    final root = Map<String, dynamic>.from(data);
    final raw = root['request'];
    final model = raw is Map
        ? OtherRequestModel.fromMap(Map<String, dynamic>.from(raw))
        : null;

    return {
      'ok': root['ok'] == true,
      'request': model?.toMap(),
      'error': root['error'],
    };
  }

  Future<OrderModel?> getMyOrderModel(int orderId) async {
    final res = await ApiClient.I.dio.get('/client/orders/$orderId');
    final data = res.data;

    if (data is! Map) {
      throw Exception('BAD_RESPONSE');
    }

    final root = Map<String, dynamic>.from(data);
    final orderRaw = root['order'];
    if (root['ok'] != true || orderRaw is! Map) return null;

    return OrderModel.fromMap(Map<String, dynamic>.from(orderRaw));
  }

  Future<List<OrderItemModel>> getMyOrderItemModels(int orderId) async {
    final res = await ApiClient.I.dio.get('/client/orders/$orderId');
    final data = res.data;

    if (data is! Map) {
      throw Exception('BAD_RESPONSE');
    }

    final root = Map<String, dynamic>.from(data);
    final itemsRaw = (root['items'] as List?) ?? const [];

    return itemsRaw
        .whereType<Map>()
        .map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
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

      final orderModel = orderRaw is Map
          ? OrderModel.fromMap(Map<String, dynamic>.from(orderRaw))
          : null;
      final itemModels = itemsRaw
          .whereType<Map>()
          .map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();

      final result = {
        'ok': root['ok'] == true,
        'order': orderModel?.toMap(includeType: false),
        'items': itemModels.map((e) => e.toMap()).toList(),
        'error': root['error'],
      };

      final order = result['order'];
      final items = result['items'];

      if (result['ok'] == true &&
          order is Map<String, dynamic> &&
          items is List) {
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
