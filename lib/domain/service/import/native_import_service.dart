import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/editor/json_document_factory.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models.dart';

import 'document_import_service.dart';

typedef MultiTableChooser = Future<List<Worksheet>> Function(List<Worksheet>);

/// Loads documents from native file format
class NativeImporterService extends DocumentImporter {
  final MultiTableChooser? tableChooser;

  const NativeImporterService({this.tableChooser});

  @override
  Future<Document?> doImport(String filePath) async {
    final documentFile = File(filePath);

    final fileContent = await documentFile.readAsString();
    final jsonData = jsonDecode(fileContent);

    final documentFactory = JsonDocumentFactory(
      jsonData,
      savePath: documentFile,
    );

    final document = await documentFactory.createDocument();

    final optDocument = tableChooser == null
        ? document
        : await _chooseWorksheets(document, tableChooser!);

    return optDocument;
  }

  Future<Document?> _chooseWorksheets(
      Document document, MultiTableChooser tableChooser) async {
    final worksheets = await _chooseWorksheets0(document, tableChooser);

    if (worksheets.isEmpty) {
      return null;
    }

    document.worksheets
      ..removeAll()
      ..addWorksheets(worksheets);
    return document;
  }

  Future<List<Worksheet>> _chooseWorksheets0(
      Document document, MultiTableChooser tableChooser) async {
    final worksheets = document.worksheets.list;
    return worksheets.length == 1
        ? Future.value(worksheets)
        : tableChooser(worksheets);
  }
}
