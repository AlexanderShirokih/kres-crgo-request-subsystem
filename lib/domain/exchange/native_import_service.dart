import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/editor/json_document_factory.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models.dart';

import 'document_import_service.dart';

typedef MultiTableChooser = Future<List<Worksheet>> Function(List<Worksheet>);

/// Loads documents from native file format
class NativeImporterService implements DocumentImporterService {
  final MultiTableChooser? tableChooser;
  final StreamedRepositoryController<RecentDocumentInfo> _repositoryController;

  const NativeImporterService(
    this._repositoryController, {
    this.tableChooser,
  });

  @override
  Future<Document?> importDocument(String filePath) async {
    final documentFile = File(filePath);

    final fileContent = await documentFile.readAsString();
    final jsonData = jsonDecode(fileContent);

    final documentFactory = JsonDocumentFactory(jsonData, documentFile);
    final document = documentFactory.createDocument();

    final optDocument = tableChooser == null
        ? document
        : await _chooseWorksheets(document, tableChooser!);

    // Register file in the recent documents list
    _repositoryController.add(RecentDocumentInfo(path: documentFile));
    await _repositoryController.commit();

    return optDocument;
  }

  Future<Document?> _chooseWorksheets(
      Document document, MultiTableChooser tableChooser) async {
    final worksheets = await _chooseWorksheets0(document, tableChooser);
    return worksheets.isEmpty ? null : (document..setWorksheets(worksheets));
  }

  Future<List<Worksheet>> _chooseWorksheets0(
      Document document, MultiTableChooser tableChooser) async {
    final worksheets = document.currentWorksheets;
    return worksheets.length == 1
        ? Future.value(worksheets)
        : tableChooser(worksheets);
  }
}
