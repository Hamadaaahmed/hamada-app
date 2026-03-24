import 'app_database.dart';

class DB {
  static final DB I = DB._();

  DB._();

  final AppDatabase database = AppDatabase();
}
