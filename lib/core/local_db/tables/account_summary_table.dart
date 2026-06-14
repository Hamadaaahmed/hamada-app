import 'package:drift/drift.dart';

class CachedAccountSummaries extends Table {
  IntColumn get clientId => integer().named('client_id')();

  TextColumn get phone =>
      text().withDefault(const Constant(''))();

  IntColumn get walletCents =>
      integer().named('wallet_cents').withDefault(const Constant(0))();

  IntColumn get debtCents =>
      integer().named('debt_cents').withDefault(const Constant(0))();

  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {clientId};
}
