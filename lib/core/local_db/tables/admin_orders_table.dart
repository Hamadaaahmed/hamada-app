import 'package:drift/drift.dart';

class CachedAdminOrders extends Table {
  IntColumn get id => integer()();

  IntColumn get clientId =>
      integer().named('client_id').withDefault(const Constant(0))();

  TextColumn get email =>
      text().withDefault(const Constant(''))();

  TextColumn get phone =>
      text().withDefault(const Constant(''))();

  RealColumn get lat => real().nullable()();

  RealColumn get lng => real().nullable()();

  RealColumn get accuracyM =>
      real().named('accuracy_m').nullable()();

  TextColumn get status =>
      text().withDefault(const Constant(''))();

  IntColumn get totalCents =>
      integer().named('total_cents').withDefault(const Constant(0))();

  IntColumn get paidCents =>
      integer().named('paid_cents').withDefault(const Constant(0))();

  TextColumn get adminNote =>
      text().named('admin_note').nullable()();

  TextColumn get rejectReason =>
      text().named('reject_reason').nullable()();

  TextColumn get scheduledAt =>
      text().named('scheduled_at').nullable()();

  TextColumn get completedAt =>
      text().named('completed_at').nullable()();

  TextColumn get createdAt =>
      text().named('created_at').nullable()();

  DateTimeColumn get cachedAt =>
      dateTime().named('cached_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
