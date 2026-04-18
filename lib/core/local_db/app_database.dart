import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/account_summary_table.dart';
import 'tables/admin_client_accounts_table.dart';
import 'tables/admin_clients_table.dart';
import 'tables/admin_orders_table.dart';
import 'tables/admin_posts_table.dart';
import 'tables/announcements_table.dart';
import 'tables/client_order_details_table.dart';
import 'tables/client_orders_table.dart';
import 'tables/machines_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CachedMachines,
    CachedAnnouncements,
    CachedAccountSummaries,
    CachedAdminPosts,
    CachedClientOrders,
    CachedClientOrderDetails,
    CachedAdminOrders,
    CachedAdminClients,
    CachedAdminClientAccounts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 9;

  Future<void> replaceMachines(List<CachedMachinesCompanion> rows) async {
    await transaction(() async {
      await delete(cachedMachines).go();
      if (rows.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(cachedMachines, rows);
        });
      }
    });
  }

  Future<List<CachedMachine>> getMachines() {
    return (select(cachedMachines)
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
            (t) => OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  Future<void> saveAnnouncement(CachedAnnouncementsCompanion row) async {
    await into(cachedAnnouncements).insertOnConflictUpdate(row);
  }

  Future<CachedAnnouncement?> getAnnouncement() {
    return (select(cachedAnnouncements)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
  }

  Future<void> saveAccountSummary(
    CachedAccountSummariesCompanion row,
  ) async {
    await into(cachedAccountSummaries).insertOnConflictUpdate(row);
  }

  Future<CachedAccountSummary?> getAccountSummary(int clientIdValue) {
    return (select(cachedAccountSummaries)
          ..where((t) => t.clientId.equals(clientIdValue)))
        .getSingleOrNull();
  }

  Future<void> replaceAdminPosts(List<CachedAdminPostsCompanion> rows) async {
    await transaction(() async {
      await delete(cachedAdminPosts).go();
      if (rows.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(cachedAdminPosts, rows);
        });
      }
    });
  }

  Future<List<CachedAdminPost>> getAdminPosts() {
    return (select(cachedAdminPosts)
          ..orderBy([
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<void> replaceClientOrders(List<CachedClientOrdersCompanion> rows) async {
    await transaction(() async {
      await delete(cachedClientOrders).go();
      if (rows.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(cachedClientOrders, rows);
        });
      }
    });
  }

  Future<List<CachedClientOrder>> getClientOrders() {
    return (select(cachedClientOrders)
          ..orderBy([
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<void> saveClientOrderDetails(
    CachedClientOrderDetailsCompanion row,
  ) async {
    await into(cachedClientOrderDetails).insertOnConflictUpdate(row);
  }

  Future<CachedClientOrderDetail?> getClientOrderDetails(int orderIdValue) {
    return (select(cachedClientOrderDetails)
          ..where((t) => t.orderId.equals(orderIdValue)))
        .getSingleOrNull();
  }

  Future<void> replaceAdminOrders(List<CachedAdminOrdersCompanion> rows) async {
    await transaction(() async {
      await delete(cachedAdminOrders).go();
      if (rows.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(cachedAdminOrders, rows);
        });
      }
    });
  }

  Future<List<CachedAdminOrder>> getAdminOrders() {
    return (select(cachedAdminOrders)
          ..orderBy([
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<void> replaceAdminClients(List<CachedAdminClientsCompanion> rows) async {
    await transaction(() async {
      await delete(cachedAdminClients).go();
      if (rows.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(cachedAdminClients, rows);
        });
      }
    });
  }

  Future<List<CachedAdminClient>> getAdminClients() {
    return (select(cachedAdminClients)
          ..orderBy([
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<void> saveAdminClientAccount(
    CachedAdminClientAccountsCompanion row,
  ) async {
    await into(cachedAdminClientAccounts).insertOnConflictUpdate(row);
  }

  Future<CachedAdminClientAccount?> getAdminClientAccount(int id) {
    return (select(cachedAdminClientAccounts)
          ..where((t) => t.clientId.equals(id)))
        .getSingleOrNull();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'hamada_cache.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
