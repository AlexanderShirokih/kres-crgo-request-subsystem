import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/process_result.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'package:kres_requests2/core/counters_importer.dart';
import 'package:kres_requests2/data/document.dart';
import 'package:kres_requests2/data/request_entity.dart';
import 'package:kres_requests2/data/worksheet.dart';

class ImporterException implements Exception {
  final String message;
  final Object parent;

  const ImporterException(this.message, [this.parent]);

  @override
  String toString() =>
      '$ImporterException: $message. ${parent == null ? '' : 'Parental exception: $parent'}';
}

abstract class WorksheetImporter {
  const WorksheetImporter();

  /// Runs parser program and returns worksheets containing parsing result
  Future<Document> importDocument(String filePath);
}

class ImporterProcessMissingException implements Exception {}

class RequestsWorksheetImporter extends WorksheetImporter {
  final String importerExecutablePath;

  const RequestsWorksheetImporter({
    @required this.importerExecutablePath,
  }) : assert(importerExecutablePath != null);

  String _getWorksheetName(String filePath) =>
      path.basenameWithoutExtension(filePath);

  Future<bool> _checkExporter() => File(importerExecutablePath).exists();

  @override
  Future<Document> importDocument(String filePath) =>
      _checkExporter().then((isExists) {
        if (!isExists) throw ImporterProcessMissingException();
      }).then(
        (value) => _importRequests(filePath)
            .then(
              (requests) => requests.isEmpty
                  ? null
                  : [
                      Worksheet(
                        name: _getWorksheetName(filePath),
                        requests: requests,
                      )
                    ],
            )
            .then(
              (worksheets) =>
                  worksheets == null ? null : Document(worksheets: worksheets),
            ),
      );

  Future<List<RequestEntity>> _importRequests(String filePath) => Process.run(
        File(importerExecutablePath).absolute.path,
        ['-parse', filePath],
      )
          .then(
        (ProcessResult result) => result.exitCode != 0
            ? RequestsProcessResult(error: "Parsing error!\n${result.stderr}")
            : RequestsProcessResult.fromJson(
                jsonDecode(result.stdout),
                (d) => (d as List<dynamic>)
                    .map((e) => RequestEntity.fromJson(e))
                    .toList()),
      )
          .then((value) {
        if (value.hasError()) throw (value.createException());
        return value.data;
      });
}

class CountersWorksheetImporter extends WorksheetImporter {
  final CountersImporter importer;
  final TableChooser tableChooser;

  const CountersWorksheetImporter({
    @required this.importer,
    @required this.tableChooser,
  })  : assert(importer != null),
        assert(tableChooser != null);

  @override
  Future<Document> importDocument(String filePath) {
    return _doImport(filePath)
        .then(
          (namedRequests) => namedRequests.requests.isEmpty
              ? null
              : [
                  Worksheet(
                    name: namedRequests.name,
                    requests: namedRequests.requests,
                  )
                ],
        )
        .then(
          (worksheets) =>
              worksheets == null ? null : Document(worksheets: worksheets),
        );
  }

  Future<NamedWorksheet> _doImport(String filePath) =>
      importer.importAsRequestsList(filePath, tableChooser);
}

typedef MultiTableChooser = Future<List<Worksheet>> Function(List<Worksheet>);

class NativeWorksheetImporter extends WorksheetImporter {
  final MultiTableChooser tableChooser;

  const NativeWorksheetImporter({@required this.tableChooser});

  @override
  Future<Document> importDocument(String filePath) => File(filePath)
      .readAsString()
      .then((content) => jsonDecode(content))
      .then((json) => Document.fromJson(json))
      .then((document) =>
          tableChooser == null ? document : _chooseWorksheets(document));

  Future<Document> _chooseWorksheets(Document document) =>
      _chooseWorksheets0(document).then(
        (worksheets) => worksheets == null || worksheets.isEmpty
            ? null
            : Document(worksheets: worksheets),
      );

  Future<List<Worksheet>> _chooseWorksheets0(Document document) =>
      document.worksheets.length == 1
          ? Future.sync(() => document.worksheets)
          : tableChooser(document.worksheets);
}
