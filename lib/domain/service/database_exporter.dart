import 'dart:io';

import 'package:kres_requests2/data/export/table_exporter.dart';

/// Makes database dumps. [entities] order is important to resolve FK!
class DatabaseExporter {
  final List<ExportableEntity> entities;

  DatabaseExporter(this.entities);

  Future<void> makeDumpTo(File file) async {
    final IOSink sink = file.openWrite(mode: FileMode.write);
    final date = DateTime.now();

    try {
      // Write heading
      sink.writeln("--app:schema=1");
      sink.writeln();

      sink.writeln("-- Export date: $date");
      sink.writeln();

      sink.writeln("-- !! WARNING !!");
      sink.writeln('-- ALL DATA IN YOUR TABLES WILL BE ERASED!');
      sink.writeln('-- ВСЕ ДАННЫЕ В ВАШИХ ТАБЛИЦАХ БУДУТ СТЕРТЫ!');
      sink.writeln();

      // Drop the current tables
      for (final entity in entities.reversed) {
        entity.makeDeleteSql(sink);
      }

      // Write tables
      for (final entity in entities) {
        await entity.makeDump(sink);
      }
    } finally {
      await sink.close();
    }
  }
}
