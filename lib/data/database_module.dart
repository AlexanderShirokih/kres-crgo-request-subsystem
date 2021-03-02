import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// DI container for application database
class DatabaseModule {
  final Database database;

  DatabaseModule(this.database);

  /// Creates new database module with new database
  static Future<DatabaseModule> build() async =>
      DatabaseModule(await AppDatabase.instance.database);

  Future<void> dispose() => database.close();
}
