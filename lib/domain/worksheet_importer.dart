import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/worksheet.dart';

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
  final AbstractRequestProcessor requestProcessor;

  const RequestsWorksheetImporter({
    @required this.requestProcessor,
  }) : assert(requestProcessor != null);

  @override
  Future<Document> importDocument(String filePath) =>
      requestProcessor.isAvailable().then((isExists) {
        if (!isExists) throw ImporterProcessMissingException();
      }).then((value) async {
        final result = await requestProcessor.importRequests(filePath);
        if (result.hasError()) throw result.createException();
        return result.data;
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
