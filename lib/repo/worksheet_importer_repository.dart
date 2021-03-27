import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/editor/document_factory.dart';
import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/worksheet.dart';

abstract class WorksheetImporterRepository {
  const WorksheetImporterRepository();

  /// Runs parser program and returns document containing parsing result
  Future<Document?> importDocument(String filePath);
}

class CountersImporterRepository extends WorksheetImporterRepository {
  final CountersImporter importer;

  final TableChooser tableChooser;

  const CountersImporterRepository({
    required this.importer,
    required this.tableChooser,
  });

  @override
  Future<Document?> importDocument(String filePath) async {
    final namedRequests =
        await importer.importAsRequestsList(filePath, tableChooser);

    if (namedRequests.requests.isEmpty) {
      return null;
    }

    final worksheets = [
      Worksheet(
        name: namedRequests.name,
        requests: namedRequests.requests,
      )
    ];

    return Document(
      worksheets: worksheets,
      updateDate: DateTime.now(),
    );
  }
}

typedef MultiTableChooser = Future<List<Worksheet>> Function(List<Worksheet>);

/// Create documents from native file format
class NativeImporterRepository extends WorksheetImporterRepository {
  final MultiTableChooser? _tableChooser;

  const NativeImporterRepository([this._tableChooser]);

  @override
  Future<Document?> importDocument(String filePath) async {
    final documentFile = File(filePath);

    final fileContent = await documentFile.readAsString();
    final jsonData = jsonDecode(fileContent);

    final documentFactory = JsonDocumentFactory(jsonData, documentFile);
    final document = documentFactory.createDocument();

    final optDocument = _tableChooser == null
        ? document
        : await _chooseWorksheets(document, _tableChooser!);

    return optDocument;
  }

  Future<Document?> _chooseWorksheets(
      Document document, MultiTableChooser tableChooser) async {
    final worksheets = await _chooseWorksheets0(document, tableChooser);
    return worksheets.isEmpty ? null : (document..setWorksheets(worksheets));
  }

  Future<List<Worksheet>> _chooseWorksheets0(
      Document document, MultiTableChooser tableChooser) async {
    final worksheets = await document.worksheets.first;
    return worksheets.length == 1
        ? Future.value(worksheets)
        : tableChooser(worksheets);
  }
}
