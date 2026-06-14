import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/api_client.dart';
import '../../../core/local_db/app_database.dart';
import '../../../core/local_db/db.dart';

class AdminClientAccountService {
  bool _asBool(dynamic v) {
    final s = '${v ?? ''}'.trim().toLowerCase();
    return v == true || s == 'true' || s == '1';
  }

  String _normalizeKind(dynamic v) {
    final s = (v ?? '').toString().trim().toLowerCase();
    if (s == 'debit') return 'debt';
    return s;
  }

  Future<Map<String, dynamic>> getAccount(int clientId) async {
    try {
      final res = await ApiClient.I.dio.get('/admin/clients/$clientId/account');
      final root = Map<String, dynamic>.from(res.data as Map);

      final clientMap =
          root['client'] is Map ? Map<String, dynamic>.from(root['client'] as Map) : null;

      final result = {
        'ok': root['ok'] == true,
        'client': clientMap == null
            ? null
            : {
                'id': int.tryParse('${clientMap['id']}') ?? 0,
                'email': (clientMap['email'] ?? '').toString(),
                'phone': (clientMap['phone'] ?? '').toString(),
                'blocked': _asBool(clientMap['blocked']),
                'active': _asBool(clientMap['active']),
              },
        'wallet_cents': int.tryParse('${root['wallet_cents']}') ?? 0,
        'debt_cents': int.tryParse('${root['debt_cents']}') ?? 0,
        'net_cents': int.tryParse('${root['net_cents']}') ?? 0,
        'entries': ((root['entries'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => {
                  'id': int.tryParse('${e['id']}') ?? 0,
                  'kind': _normalizeKind(e['kind']),
                  'amount_cents': int.tryParse('${e['amount_cents']}') ?? 0,
                  'note': (e['note'] ?? '').toString(),
                  'created_at': (e['created_at'] ?? '').toString(),
                })
            .toList(),
        'error': root['error'],
      };

      await DB.I.database.saveAdminClientAccount(
        CachedAdminClientAccountsCompanion(
          clientId: Value(clientId),
          clientJson: Value(jsonEncode(result['client'] ?? const {})),
          walletCents: Value(result['wallet_cents'] as int? ?? 0),
          debtCents: Value(result['debt_cents'] as int? ?? 0),
          netCents: Value(result['net_cents'] as int? ?? 0),
          entriesJson: Value(jsonEncode(result['entries'] ?? const [])),
          cachedAt: Value(DateTime.now()),
        ),
      );

      return result;
    } catch (_) {
      final cached = await DB.I.database.getAdminClientAccount(clientId);

      if (cached == null) {
        return {
          'ok': false,
          'client': null,
          'wallet_cents': 0,
          'debt_cents': 0,
          'net_cents': 0,
          'entries': const [],
          'error': 'CACHE_EMPTY',
        };
      }

      return {
        'ok': true,
        'client': jsonDecode(cached.clientJson),
        'wallet_cents': cached.walletCents,
        'debt_cents': cached.debtCents,
        'net_cents': cached.netCents,
        'entries': jsonDecode(cached.entriesJson),
        'error': null,
      };
    }
  }

  Future<Map<String, dynamic>> addCredit({
    required int clientId,
    required int amountCents,
    required String note,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/clients/$clientId/account/credit',
      data: {
        'amount_cents': amountCents,
        'note': note,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> addDebt({
    required int clientId,
    required int amountCents,
    required String note,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/clients/$clientId/account/debt',
      data: {
        'amount_cents': amountCents,
        'note': note,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> addNote({
    required int clientId,
    required String note,
  }) async {
    final res = await ApiClient.I.dio.post(
      '/admin/clients/$clientId/account/note',
      data: {
        'note': note,
      },
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> blockClient(int clientId) async {
    final res = await ApiClient.I.dio.post('/admin/clients/$clientId/block');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> unblockClient(int clientId) async {
    final res = await ApiClient.I.dio.post('/admin/clients/$clientId/unblock');
    return Map<String, dynamic>.from(res.data as Map);
  }
}
