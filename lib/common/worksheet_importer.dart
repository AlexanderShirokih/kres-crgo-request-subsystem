import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/request_entity.dart';
import 'package:kres_requests2/data/worksheet.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

abstract class WorksheetImporter {
  const WorksheetImporter();

  /// Runs parser program and returns worksheet containing parsing result
  Future<Worksheet> importWorksheet(String filePath);
}

class RequestsWorksheetImporter extends WorksheetImporter {
  final String importerExecutablePath;

  const RequestsWorksheetImporter({
    @required this.importerExecutablePath,
  }) : assert(importerExecutablePath != null);

  String _getWorksheetName(String filePath) =>
      path.basenameWithoutExtension(filePath);

  @override
  Future<Worksheet> importWorksheet(String filePath) {
    return _importRequests(filePath).then(
      (requests) => Worksheet(
        name: _getWorksheetName(filePath),
        requests: requests,
      ),
    );
  }

  Future<List<RequestEntity>> _importRequests(String filePath) =>
      Process.run(importerExecutablePath, ['-parse', filePath])
          .then((ProcessResult result) => result.exitCode != 0
              ? {"error": "Parsing error!\n${result.stderr}"}
              : jsonDecode(result.stdout))
          .then((value) {
        if (value['error'] != null) throw (value['error']);
        return (value['data'] as List<dynamic>)
            .map((e) => RequestEntity.fromJson(e))
            .toList();
      });
}
