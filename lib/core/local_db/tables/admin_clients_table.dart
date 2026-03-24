import 'package:drift/drift.dart';

class CachedAdminClients extends Table {
  IntColumn get id => integer()();

  TextColumn get email =>
      text().withDefault(const Constant(''))();

  TextColumn get phone =>
      text().withDefault(const Constant(''))();

  BoolColumn get blocked =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get cachedAt =>
      dateTime().named('cached_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
