import 'package:drift/drift.dart';

class CachedAdminPosts extends Table {
  IntColumn get id => integer()();

  TextColumn get message =>
      text().withDefault(const Constant(''))();

  TextColumn get imageUrl =>
      text().named('image_url').withDefault(const Constant(''))();

  IntColumn get version =>
      integer().withDefault(const Constant(1))();

  BoolColumn get isActive =>
      boolean().named('is_active')
          .withDefault(const Constant(true))();

  TextColumn get createdAt =>
      text().named('created_at').withDefault(const Constant(''))();

  TextColumn get updatedAt =>
      text().named('updated_at').withDefault(const Constant(''))();

  DateTimeColumn get cachedAt =>
      dateTime().named('cached_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
