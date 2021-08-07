import 'dart:io';

import 'package:kres_requests2/data/datasource/app_database.dart';

/// Makes a dump of certain table
mixin ExportableEntity {
  /// App database instance
  AppDatabase get database;

  /// The table name
  String get tableName;

  /// Writes SQL query that deletes data in the table
  void makeDeleteSql(IOSink sink) {
    sink.writeln("DELETE FROM $tableName;");
    sink.writeln();
  }

  /// Dump whole table to [sink]
  Future<void> makeDump(IOSink sink) async {
    final db = await database.database;

    final List<Map<String, dynamic>> rows =
        await db.rawQuery('SELECT * FROM $tableName');

    sink.writeln("-- Table '$tableName'");

    if (rows.isEmpty) {
      sink.writeln("-- table is empty!");
    } else {
      final keys = rows.first.keys.toList(growable: false);
      final fields = keys.join(',');

      sink.writeln('INSERT INTO $tableName ($fields)');
      sink.writeln('VALUES');

      final rowsCount = rows.length;
      for (int i = 0; i < rowsCount; i++) {
        final isLast = i == rowsCount - 1;
        final row = rows[i];
        final rowKeys = row.keys;

        if (rowKeys.length != keys.length) {
          throw 'Columns count is different; Expected: $keys. Got: ${rowKeys.toList()}.';
        }

        final values = keys.map((column) {
          final value = row[column];
          return value is String ? "'$value'" : value;
        }).join(',');

        sink.write('($values)');
        sink.writeln(isLast ? ";" : ",");
      }

      sink.writeln();
    }

    sink.writeln();
  }
}
