import 'package:drift/drift.dart';

class CachedAnnouncements extends Table {
  IntColumn get id =>
      integer().withDefault(const Constant(1))();

  TextColumn get message =>
      text().withDefault(const Constant(''))();

  BoolColumn get isActive =>
      boolean().named('is_active')
          .withDefault(const Constant(true))();

  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
