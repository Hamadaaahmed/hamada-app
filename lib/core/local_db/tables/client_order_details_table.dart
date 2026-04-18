import 'package:drift/drift.dart';

class CachedClientOrderDetails extends Table {
  IntColumn get orderId => integer().named('order_id')();

  TextColumn get orderJson =>
      text().named('order_json').withDefault(const Constant(''))();

  TextColumn get itemsJson =>
      text().named('items_json').withDefault(const Constant('[]'))();

  DateTimeColumn get cachedAt =>
      dateTime().named('cached_at')();

  @override
  Set<Column<Object>> get primaryKey => {orderId};
}
