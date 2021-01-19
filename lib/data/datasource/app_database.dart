// App database holder
import 'dart:async';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  static const String _dbName = 'main.db';

  static final AppDatabase _instance = AppDatabase._();

  Completer<Database> _dbOpenCompleter;

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
    return _dbOpenCompleter.future;
  }

  Future<void> _openDatabase() async {
    // Get application files directory
    final appDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDir.path, _dbName);

    // Open the database
    final database = await databaseFactoryIo.openDatabase(dbPath);

    _dbOpenCompleter.complete(database);
  }
}
