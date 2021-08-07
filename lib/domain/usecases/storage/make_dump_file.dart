import 'dart:io';

import 'package:kres_requests2/domain/service/database_exporter.dart';
import 'package:path/path.dart';

/// Creates database dump file
class MakeDatabaseDump {
  final DatabaseExporter databaseExporter;

  const MakeDatabaseDump(
    this.databaseExporter,
  );

  Future<void> call(String dumpDirectory) async {
    final date = DateTime.now().millisecondsSinceEpoch;

    final path = join(dumpDirectory, "dump_$date.sql");
    final file = File(path);

    await file.create();

    await databaseExporter.makeDumpTo(file);
  }
}
