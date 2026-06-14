import 'package:drift/drift.dart';

class CachedMachines extends Table {
  IntColumn get id => integer()();

  TextColumn get name => text()();

  TextColumn get icon =>
      text().withDefault(const Constant('🧵'))();

  IntColumn get priceCents =>
      integer().named('price_cents')();

  BoolColumn get active =>
      boolean().withDefault(const Constant(true))();

  IntColumn get sortOrder =>
      integer().named('sort_order').withDefault(const Constant(0))();

  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
