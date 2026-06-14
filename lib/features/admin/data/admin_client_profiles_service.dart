import '../../../core/api_client.dart';

class AdminClientProfilesService {
  Future<List<Map<String, dynamic>>> listClients() async {
    final res = await ApiClient.I.dio.get('/admin/clients');
    final data = res.data;
    if (data is! Map) return <Map<String, dynamic>>[];

    final root = Map<String, dynamic>.from(data);
    final raw = (root['clients'] as List?) ?? const [];

    return raw.whereType<Map>().map((e) {
      final map = Map<String, dynamic>.from(e);
      return {
        'id': int.tryParse('${map['id']}') ?? 0,
        'email': (map['email'] ?? '').toString(),
        'phone': (map['phone'] ?? '').toString(),
        'blocked': map['blocked'] == true ||
            '${map['blocked']}'.toLowerCase() == 'true',
      };
    }).toList();
  }

  Future<Map<String, dynamic>> updateClientProfile({
    required int clientId,
    required String email,
    required String phone,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/clients/$clientId/profile',
      data: {
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
      },
    );

    if (res.data is! Map) {
      return {'ok': false, 'error': 'BAD_RESPONSE'};
    }

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> deleteClient({
    required int clientId,
  }) async {
    final res = await ApiClient.I.dio.post('/admin/clients/$clientId/delete');

    if (res.data is! Map) {
      return {'ok': false, 'error': 'BAD_RESPONSE'};
    }

    return Map<String, dynamic>.from(res.data as Map);
  }
}
