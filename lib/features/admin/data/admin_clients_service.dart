import 'package:drift/drift.dart';

import '../../../core/api_client.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/local_db/db.dart';

class AdminClientsService {
  Future<List<Map<String, dynamic>>> listClients() async {
    try {
      final res = await ApiClient.I.dio.get('/admin/clients');
      final data = res.data;

      if (data is! Map) {
        throw Exception('BAD_RESPONSE');
      }

      final root = Map<String, dynamic>.from(data);
      final raw = (root['clients'] as List?) ?? const [];

      final list = raw.whereType<Map>().map((e) {
        final map = Map<String, dynamic>.from(e);
        return {
          'id': int.tryParse('${map['id']}') ?? 0,
          'email': (map['email'] ?? '').toString(),
          'phone': (map['phone'] ?? '').toString(),
          'blocked': map['blocked'] == true ||
              '${map['blocked']}'.toLowerCase() == 'true',
        };
      }).toList();

      final rows = list.map((c) {
        return CachedAdminClientsCompanion(
          id: Value(c['id'] as int),
          email: Value((c['email'] ?? '').toString()),
          phone: Value((c['phone'] ?? '').toString()),
          blocked: Value(c['blocked'] == true),
          cachedAt: Value(DateTime.now()),
        );
      }).toList();

      await DB.I.database.replaceAdminClients(rows);
      return list;
    } catch (_) {
      final cached = await DB.I.database.getAdminClients();
      return cached.map((c) {
        return {
          'id': c.id,
          'email': c.email,
          'phone': c.phone,
          'blocked': c.blocked,
        };
      }).toList();
    }
  }
}
