import 'dart:io';

import 'package:kres_requests2/data/datasource/app_database.dart';

/// Executes SQL code on the database
class DatabaseImporter {
  final AppDatabase _appDatabase;

  DatabaseImporter(this._appDatabase);

  Future<void> call(String importFilePath) async {
    final file = File(importFilePath);

    /// OMG! Read the whole file. Maybe better to split file by queries.
    final sql = await file.readAsString();

    if (sql.isNotEmpty) {
      final db = await _appDatabase.database;
      await db.execute(sql);
    }
  }
}
