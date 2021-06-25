import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/editor/json_document_factory.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';

import 'document_import_service.dart';

typedef MultiTableChooser = Future<List<Worksheet>> Function(List<Worksheet>);

/// Loads documents from native file format
class NativeImporterService implements DocumentImporter {
  final MultiTableChooser? tableChooser;
  final StreamedRepositoryController<RecentDocumentInfo> _repositoryController;

  const NativeImporterService(
    this._repositoryController, {
    this.tableChooser,
  });

  @override
  Future<bool> importDocument(String filePath, DocumentManager manager) async {
    final documentFile = File(filePath);

    final fileContent = await documentFile.readAsString();
    final jsonData = jsonDecode(fileContent);

    final documentFactory = JsonDocumentFactory(jsonData, documentFile);
    final document = documentFactory.createDocument();

    final optDocument = tableChooser == null
        ? document
        : await _chooseWorksheets(document, tableChooser!);

    // Register file in the recent documents list
    // TODO: MOVE THIS CODE TO THE [DocumentManager]
    _repositoryController.add(RecentDocumentInfo(path: documentFile));
    await _repositoryController.commit();

    // Register document in the document manager
    if(optDocument != null)
    manager.addDocument(optDocument);

    return optDocument != null;
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
