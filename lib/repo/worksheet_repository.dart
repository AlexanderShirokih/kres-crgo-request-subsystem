import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/common/worksheet_creation_mode.dart';
import 'package:kres_requests2/data/document.dart';
import 'package:kres_requests2/data/request_entity.dart';
import 'package:kres_requests2/data/worksheet.dart';
import 'package:path/path.dart' as path;

class WorksheetRepository {
  final String _parsingExecPath;

  const WorksheetRepository(this._parsingExecPath)
      : assert(_parsingExecPath != null);

  /// Runs parser program and returns worksheet containing parsing result
  Future<Worksheet> importWorksheet(File requestsFilePath) =>
      _importRequests(requestsFilePath.path).then(
        (requests) => Worksheet(
          name: _getWorksheetName(requestsFilePath.path),
          requests: requests,
        ),
      );

  String _getWorksheetName(String filePath) =>
      path.basenameWithoutExtension(filePath);

  Future<List<RequestEntity>> _importRequests(String requestsPath) =>
      Process.run(_parsingExecPath, ['-parse', requestsPath])
          .then((ProcessResult result) => result.exitCode != 0
              ? {"error": "Parsing error!\n${result.stderr}"}
              : jsonDecode(result.stdout))
          .then((value) {
        if (value['error'] != null) throw (value['error']);
        return (value['data'] as List<dynamic>)
            .map((e) => RequestEntity.fromJson(e))
            .toList();
      });

  Future importWorksheetByMode(Document document, WorksheetCreationMode mode,
      {String path}) {
    switch (mode) {
      case WorksheetCreationMode.EmptyRaid:
        return Future.sync(() {
          document.active = document.addEmptyRaidWorksheet();
        });
      case WorksheetCreationMode.Import:
        return _importRequests(path).then((value) {
          document
              .addEmptyWorksheet(name: _getWorksheetName(path))
              .requests
              .addAll(value);
        });
        break;
      case WorksheetCreationMode.ImportCounters:
      // TODO: Implement counters importing
      case WorksheetCreationMode.Empty:
      default:
        return Future.sync(() {
          document.active = document.addEmptyWorksheet();
        });
    }
  }
}
