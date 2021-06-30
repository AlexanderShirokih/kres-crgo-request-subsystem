import 'dart:io';

import 'package:kres_requests2/domain/editor/document_filter.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/presentation/common.dart';

enum DocumentSavingState {
  pickingSavePath,
  saving,
  saved,
}

/// Service for handling actions on document
class DocumentService {
  /// Function that returns document save path based on [Document] current
  /// working directory
  final Future<File?> Function(Document, String) _savePathChooser;
  final Document document;
  final DocumentSaver _documentSaver;
  final DocumentFilter _documentFilter;

  DocumentService(
    this.document,
    this._documentSaver,
    this._documentFilter,
    this._savePathChooser,
  );

  /// Saves the document using [DocumentSaver].
  /// Calls savePathChooser if [changePath] is `true` or current save path is
  /// not set
  Stream<DocumentSavingState> saveDocument(bool changePath) async* {
    yield DocumentSavingState.pickingSavePath;

    final savePath = await _getSavePath(changePath);

    if (savePath != null) {
      document.setSavePath(savePath);

      yield DocumentSavingState.saving;

      await document.save(_documentSaver);

      yield DocumentSavingState.saved;
    }
  }

  Future<File?> _getSavePath(bool changePath) async {
    final savePath = document.currentSavePath;

    if (savePath == null || changePath) {
      return await _savePathChooser(document, document.workingDirectory);
    }

    return savePath;
  }

  /// Adds an empty worksheet to the document
  void addEmptyWorksheet() {
    document.worksheets.add(activate: true);
  }

  /// Removes [target] worksheet from the document
  void removeWorksheet(Worksheet target) {
    document.worksheets.remove(target);
  }

  /// Makes the [target] worksheet active on the document
  void makeActive(Worksheet target) {
    document.worksheets.makeActive(target);
  }

  /// Sets the current document search text filter.
  /// When [searchText] is empty filter will be disabled
  void setSearchFilter(String searchText) {
    _documentFilter.setSearchingTest(searchText);
  }
}

/// Factory to build [DocumentService] instances
class DocumentServiceFactory {
  final DocumentSaver _documentSaver;

  DocumentServiceFactory(this._documentSaver);

  DocumentService createDocumentService(Document document) {
    return DocumentService(
      document,
      _documentSaver,
      DocumentFilter(document),
      showSaveDialog,
    );
  }
}
