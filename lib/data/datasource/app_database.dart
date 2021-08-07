import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/usecases/storage/database_path.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// App database holder
class AppDatabase extends Disposable {

  final GetDatabasePath getDatabasePath;

  Completer<Database>? _dbOpenCompleter;
  Database? _openedInstance;

  AppDatabase(this.getDatabasePath);

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

    // Get the database path
    final dbPath = await getDatabasePath();

    // Open the database
    var databaseFactory = databaseFactoryFfi;

    var db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
          version: 1,
          onConfigure: (database) async {
            await database.execute("PRAGMA foreign_keys = ON");
          },
          onCreate: (database, _) async {
            final schema = await rootBundle.loadString('assets/sql/schema.sql');
            await database.execute(schema);

            try {
              final data =
                  await rootBundle.loadString('assets/sql/autofill.sql');
              await database.execute(data);
            } catch (e) {
              // Autofill is not available, so nothing to do
            }
          }),
    );

    _openedInstance = db;
    _dbOpenCompleter!.complete(db);
  }

  @override
  void dispose() {
    _openedInstance?.close();
  }
}
