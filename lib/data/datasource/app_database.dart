// App database holder
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static const String _dbName = 'main.db';

  static final AppDatabase _instance = AppDatabase._();

  Completer<Database>? _dbOpenCompleter;

  AppDatabase._();

  /// Returns instance to database singleton
  static AppDatabase get instance => _instance;

  /// Returns opened database connection
  Future<Database> get database async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      _openDatabase();
    }

    // Await for database is opened and returns it's instance
    return _dbOpenCompleter!.future;
  }

  Future<void> _openDatabase() async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    // Get application files directory
    final appDir = await getApplicationSupportDirectory();
    final dbPath = join(appDir.path, _dbName);

    // Open the database
    var databaseFactory = databaseFactoryFfi;

    var db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, _) async {
            final schema = await rootBundle.loadString('assets/sql/schema.sql');
            await database.execute(schema);

            final data = await rootBundle.loadString('assets/sql/autofill.sql');
            await database.execute(data);
          }),
    );

    _dbOpenCompleter!.complete(db);
  }
}
