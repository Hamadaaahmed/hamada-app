import 'package:dio/dio.dart';

import '../../../core/api_client.dart';
import '../../other_requests/models/other_request_model.dart';

class AdminOtherRequestsService {
  OtherRequestModel _normalize(Map raw) {
    return OtherRequestModel.fromMap(Map<String, dynamic>.from(raw));
  }

  Future<List<OtherRequestModel>> listRequestModels(String requestKind) async {
    final path = requestKind == 'spare_part_request'
        ? '/admin/spare-part-requests'
        : '/admin/machine-requests';

    final res = await ApiClient.I.dio.get(path);
    final root = Map<String, dynamic>.from(res.data as Map);
    final raw = (root['requests'] as List?) ?? const [];
    return raw.whereType<Map>().map(_normalize).toList();
  }

  Future<List<Map<String, dynamic>>> listRequests(String requestKind) async {
    final rows = await listRequestModels(requestKind);
    return rows.map((e) => e.toMap(includeType: false)).toList();
  }

  Future<OtherRequestModel?> getRequestModel(int id) async {
    final res = await ApiClient.I.dio.get('/admin/other-requests/$id');
    final root = Map<String, dynamic>.from(res.data as Map);
    final raw = root['request'];
    if (root['ok'] != true || raw is! Map) return null;
    return _normalize(raw);
  }

  Future<Map<String, dynamic>> getRequest(int id) async {
    final res = await ApiClient.I.dio.get('/admin/other-requests/$id');
    final root = Map<String, dynamic>.from(res.data as Map);
    final raw = root['request'];
    final model = raw is Map ? _normalize(raw) : null;

    return {
      'ok': root['ok'] == true,
      'request': model?.toMap(includeType: false),
      'error': root['error'],
    };
  }

  Future<Map<String, dynamic>> quoteRequest({
    required int id,
    required int quotedPriceCents,
    String? adminNote,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/other-requests/$id/quote',
      data: {
        'quoted_price_cents': quotedPriceCents,
        if ((adminNote ?? '').trim().isNotEmpty) 'admin_note': adminNote!.trim(),
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> markUnavailable({
    required int id,
    String? adminNote,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/other-requests/$id/unavailable',
      data: {
        if ((adminNote ?? '').trim().isNotEmpty) 'admin_note': adminNote!.trim(),
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> scheduleRequest({
    required int id,
    required String scheduledAtIso,
    String? adminNote,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/other-requests/$id/schedule',
      data: {
        'scheduled_at': scheduledAtIso,
        if ((adminNote ?? '').trim().isNotEmpty) 'admin_note': adminNote!.trim(),
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> completeRequest({
    required int id,
    String? adminNote,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/other-requests/$id/complete',
      data: {
        if ((adminNote ?? '').trim().isNotEmpty) 'admin_note': adminNote!.trim(),
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  String mapError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      final apiError = data is Map ? (data['error'] ?? '').toString() : '';

      switch (apiError) {
        case 'INVALID_ID':
          return 'رقم الطلب غير صحيح';
        case 'INVALID_PRICE':
          return 'السعر غير صحيح';
        case 'INVALID_REASON':
          return 'اكتب سبب الرفض';
        case 'INVALID_DATE':
          return 'اكتب موعدًا صحيحًا';
        case 'INVALID_STATUS':
          return 'حالة الطلب لا تسمح بهذا الإجراء';
        case 'NOT_FOUND':
          return 'الطلب غير موجود';
        case 'SERVER_ERROR':
          return 'حدث خطأ في السيرفر';
      }
    }
    return 'تعذر الاتصال بالسيرفر';
  }
}
