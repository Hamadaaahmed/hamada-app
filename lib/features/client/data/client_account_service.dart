import "package:drift/drift.dart";

import "../../../core/api_client.dart";
import "../../../core/secure_storage.dart";
import "../../../core/local_db/app_database.dart";
import "../../../core/local_db/db.dart";

class ClientAccountService {
  Future<Map<String, dynamic>> getAccountSummary() async {
    try {
      final res = await ApiClient.I.dio.get('/client/accounts');
      final data = res.data;

      if (data is! Map) {
        throw Exception('BAD_RESPONSE');
      }

      final root = Map<String, dynamic>.from(data);
      final wallet = int.tryParse('${root['wallet_cents']}') ?? 0;
      final debt = int.tryParse('${root['debt_cents']}') ?? 0;

      final result = {
        'ok': root['ok'] == true,
        'phone': (root['phone'] ?? '').toString(),
        'wallet_cents': wallet,
        'debt_cents': debt,
        'net_cents': wallet - debt,
        'entries': ((root['entries'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) {
          final map = Map<String, dynamic>.from(e);
          return {
            'id': int.tryParse('${map['id']}') ?? 0,
            'kind': (map['kind'] ?? '').toString(),
            'amount_cents': int.tryParse('${map['amount_cents']}') ?? 0,
            'note': (map['note'] ?? '').toString(),
            'created_at': (map['created_at'] ?? '').toString(),
          };
        }).toList(),
        'error': root['error'],
      };

      final clientId = await AppStorage.I.getClientIdFromToken();

      await DB.I.database.saveAccountSummary(
        CachedAccountSummariesCompanion(
          clientId: Value(clientId > 0 ? clientId : 1),
          phone: Value((result['phone'] ?? '').toString()),
          walletCents: Value(wallet),
          debtCents: Value(debt),
          updatedAt: Value(DateTime.now()),
        ),
      );

      return result;
    } catch (_) {
      final fallbackClientId = await AppStorage.I.getClientIdFromToken();
      final cached = await DB.I.database.getAccountSummary(
        fallbackClientId > 0 ? fallbackClientId : 1,
      );

      if (cached == null) {
        return {
          'ok': false,
          'error': 'CACHE_EMPTY',
          'phone': '',
          'wallet_cents': 0,
          'debt_cents': 0,
          'net_cents': 0,
          'entries': const [],
        };
      }

      return {
        'ok': true,
        'error': null,
        'phone': cached.phone,
        'wallet_cents': cached.walletCents,
        'debt_cents': cached.debtCents,
        'net_cents': cached.walletCents - cached.debtCents,
        'entries': const [],
      };
    }
  }

  Future<Map<String, dynamic>> savePhone(String phone) async {
    final res = await ApiClient.I.dio.post(
      '/client/profile/phone',
      data: {'phone': phone},
    );

    final data = res.data;
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return {'ok': false, 'error': 'BAD_RESPONSE'};
  }
}
