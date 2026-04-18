import 'package:drift/drift.dart';

class CachedAdminClientAccounts extends Table {
  IntColumn get clientId => integer().named('client_id')();

  TextColumn get clientJson =>
      text().named('client_json').withDefault(const Constant('{}'))();

  IntColumn get walletCents =>
      integer().named('wallet_cents').withDefault(const Constant(0))();

  IntColumn get debtCents =>
      integer().named('debt_cents').withDefault(const Constant(0))();

  IntColumn get netCents =>
      integer().named('net_cents').withDefault(const Constant(0))();

  TextColumn get entriesJson =>
      text().named('entries_json').withDefault(const Constant('[]'))();

  DateTimeColumn get cachedAt =>
      dateTime().named('cached_at')();

  @override
  Set<Column<Object>> get primaryKey => {clientId};
}
