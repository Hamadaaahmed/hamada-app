import 'package:drift/drift.dart';

class CachedClientOrders extends Table {
  IntColumn get id => integer()();

  TextColumn get status =>
      text().withDefault(const Constant(''))();

  IntColumn get totalCents =>
      integer().named('total_cents').withDefault(const Constant(0))();

  IntColumn get paidCents =>
      integer().named('paid_cents').withDefault(const Constant(0))();

  TextColumn get adminNote =>
      text().named('admin_note').withDefault(const Constant(''))();

  TextColumn get rejectReason =>
      text().named('reject_reason').withDefault(const Constant(''))();

  TextColumn get scheduledAt =>
      text().named('scheduled_at').withDefault(const Constant(''))();

  TextColumn get completedAt =>
      text().named('completed_at').withDefault(const Constant(''))();

  TextColumn get createdAt =>
      text().named('created_at').withDefault(const Constant(''))();

  DateTimeColumn get cachedAt =>
      dateTime().named('cached_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
