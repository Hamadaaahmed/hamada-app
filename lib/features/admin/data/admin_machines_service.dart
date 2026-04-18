import 'package:drift/drift.dart';

import '../../../core/api_client.dart';
import '../../../core/firebase_messaging_service.dart';
import '../../../core/secure_storage.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/local_db/db.dart';

class AdminMachinesService {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/auth/admin/login',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final data = Map<String, dynamic>.from(res.data as Map);

    if (data['ok'] == true && (data['token'] ?? '').toString().isNotEmpty) {
      await ApiClient.I.saveAdminToken((data['token'] ?? '').toString());
      final refreshToken =
          (data['refresh_token'] ?? data['refreshToken'] ?? '').toString();
      if (refreshToken.isNotEmpty) {
        await AppStorage.I.saveAdminRefreshToken(refreshToken);
      }
      await FirebaseMessagingService.I.syncTokenToServer(role: 'admin');
    }

    return data;
  }

  Future<void> logout() async {
    await ApiClient.I.clearAdminToken();
    await AppStorage.I.clearAdminRefreshToken();
  }

  Map<String, dynamic> _normalizeMachine(Map raw) {
    return {
      'id': int.tryParse('${raw['id']}') ?? 0,
      'name': (raw['name'] ?? '').toString(),
      'icon': (raw['icon'] ?? '🧵').toString(),
      'price_cents': int.tryParse('${raw['price_cents']}') ?? 0,
      'active':
          raw['active'] == true || '${raw['active']}'.toLowerCase() == 'true',
      'sort_order': int.tryParse('${raw['sort_order']}') ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> listMachines() async {
    try {
      final res = await ApiClient.I.dio.get('/admin/machines');

      final root = Map<String, dynamic>.from(res.data as Map);

      if (root['ok'] != true) {
        throw Exception('bad');
      }

      final raw = (root['machines'] as List?) ?? const [];

      final list = raw.whereType<Map>().map(_normalizeMachine).toList();

      final rows = list.map((m) {
        return CachedMachinesCompanion(
          id: Value(m['id'] as int),
          name: Value(m['name'].toString()),
          icon: Value(m['icon'].toString()),
          priceCents: Value(m['price_cents'] as int),
          active: Value(m['active'] == true),
          sortOrder: Value(m['sort_order'] as int),
          updatedAt: Value(DateTime.now()),
        );
      }).toList();

      await DB.I.database.replaceMachines(rows);
      return list;
    } catch (_) {
      final cached = await DB.I.database.getMachines();

      return cached.map((m) {
        return {
          'id': m.id,
          'name': m.name,
          'icon': m.icon,
          'price_cents': m.priceCents,
          'active': m.active,
          'sort_order': m.sortOrder,
        };
      }).toList();
    }
  }

  Future<Map<String, dynamic>> createMachine({
    required String name,
    required String icon,
    required int priceCents,
    required int sortOrder,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/machines',
      data: {
        'name': name,
        'icon': icon,
        'price_cents': priceCents,
        'sort_order': sortOrder,
      },
    );

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> updateMachine({
    required int id,
    required String name,
    required String icon,
    required int priceCents,
    required int sortOrder,
  }) async {
    final res = await ApiClient.I.dio.put(
      '/admin/machines/$id',
      data: {
        'name': name,
        'icon': icon,
        'price_cents': priceCents,
        'sort_order': sortOrder,
      },
    );

    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> toggleMachine(int id) async {
    final res = await ApiClient.I.dio.patch('/admin/machines/$id/toggle');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> deleteMachine(int id) async {
    final res = await ApiClient.I.dio.delete('/admin/machines/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> changeAdminPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/auth/admin/change-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );

    return Map<String, dynamic>.from(res.data as Map);
  }
}
