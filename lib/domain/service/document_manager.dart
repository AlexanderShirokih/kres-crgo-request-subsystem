import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/editor/document_filter.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/export.dart';
import 'package:kres_requests2/domain/models/recent_document_info.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'export_file_chooser.dart';

class DocumentDescriptor extends Equatable {
  /// The document instance
  final Document document;

  /// Current document digest
  final String currentDigest;

  /// Digest of last saved state
  final String savedDigest;

  const DocumentDescriptor(
    this.document,
    this.currentDigest,
    this.savedDigest,
  );

  bool get hasChanges => currentDigest != savedDigest;

  @override
  List<Object?> get props => [currentDigest, savedDigest, document];
}

/// Manages opened [Document] instances
class DocumentManager {
  final BehaviorSubject<List<DocumentDescriptor>> _openedDocuments;
  final BehaviorSubject<int> _selectedIndex;

  /// Recent documents controller to add saved items into recent documents list
  final StreamedRepositoryController<RecentDocumentInfo> _repositoryController;

  /// Interface that returns a save path based on [Document] current
  /// working directory
  final ExportFileChooser _savePathChooser;

  /// Class that handles document saving
  final DocumentSaver _documentSaver;

  /// Class used to filter request by certain search criteria
  final DocumentFilter _documentFilter;

  StreamSubscription? _documentChangeListener;

  /// Creates a new document manager with empty document
  DocumentManager(
    this._savePathChooser,
    this._documentFilter,
    this._documentSaver,
    this._repositoryController,
  )   : _openedDocuments = BehaviorSubject.seeded([]),
        _selectedIndex = BehaviorSubject() {
    _documentChangeListener = openedDocumentsStream.flatMap((documents) {
      return Rx.merge(
        documents.map(
          (document) => document.worksheets.stream.map(
            (event) => document,
          ),
        ),
      ).asyncMap((changedDocument) async {
        final newDigest = await _documentSaver.digest(changedDocument);
        return DocumentDescriptor(
          changedDocument,
          newDigest,
          newDigest,
        );
      });
    }).listen((changedDocument) {
      final opened = _openedDocuments.value;
      if (opened != null) {
        final changedDocumentIndex = opened.indexWhere(
          (element) => element.document == changedDocument.document,
        );

        if (changedDocumentIndex == -1) {
          throw 'Changed document is not in opened documents list';
        }

        final current = opened[changedDocumentIndex];
        opened[changedDocumentIndex] = DocumentDescriptor(
          changedDocument.document,
          changedDocument.currentDigest,
          current.savedDigest,
        );

        _openedDocuments.add(List.of(opened));
      }
    });
  }

  /// Returns a list of unsaved documents
  List<Document> get unsaved =>
      _openedDocuments.value
          ?.where((element) => element.hasChanges)
          .map((e) => e.document)
          .toList(growable: false) ??
      <Document>[];

  /// Returns a stream of opened documents. Returned list is unmodifiable.
  Stream<List<Document>> get openedDocumentsStream => _openedDocuments.stream
      .map(
        (list) => list
            .map((descriptor) => descriptor.document)
            .toList(growable: false),
      )
      .distinct(const ListEquality().equals);

  /// Returns a list of currently opened documents
  List<Document> get opened =>
      _openedDocuments.value
          ?.map((handle) => handle.document)
          .toList(growable: false) ??
      const <Document>[];

  /// Returns a stream of documents with its meta info
  Stream<List<DocumentDescriptor>> get openedDocumentDescriptors =>
      _openedDocuments.stream;

  /// Returns a stream with currently selected document
  Stream<Document?> get selectedStream => _selectedIndex.map((index) {
        final opened = _openedDocuments.requireValue;
        return index == -1 || opened.isEmpty ? null : opened[index].document;
      }).distinct();

  /// Returns currently selected document or `null` if there is no opened documents
  Document? get selected {
    final opened = _openedDocuments.value;
    final selected = _selectedIndex.value;

    if (opened == null || selected == null) {
      return null;
    }

    return opened[selected].document;
  }

  /// Closes internal resources and all opened documents
  Future<void> dispose() async {
    await _documentChangeListener?.cancel();

    for (final handle in _openedDocuments.requireValue) {
      await handle.document.close();
    }

    await _openedDocuments.close();
    await _selectedIndex.close();
  }

  /// Adds [document] to the opened document list
  Future<void> addDocument(Document document) async {
    final opened = _openedDocuments.requireValue;
    if (opened.contains(document)) {
      // Document is already opened
      return;
    }

    await _addDocument(document);
  }

  /// Marks the [document] as selected
  void markSelected(Document document) {
    final index = _openedDocuments.requireValue
        .indexWhere((handle) => handle.document == document);

    if (index == -1) {
      throw 'Given document is not in the document list';
    }

    _selectedIndex.add(index);
  }

  /// Creates an empty document and adds it to the opened document list.
  /// Returns an instance of the opened document.
  /// Until force is `true` new document instances will not be created if empty
  /// document already exists
  Future<Document> createNew([bool force = false]) async {
    if (!force) {
      final emptyDocument =
          opened.firstWhereOrNull((doc) => doc.worksheets.isEmpty);

      if (emptyDocument != null) {
        return emptyDocument;
      }
    }

    final document = Document.empty();

    await _addDocument(document);

    return document;
  }

  /// Closes all opened document instances
  Future<void> closeAll() async {
    for (final doc in opened) {
      await doc.close();
    }

    _openedDocuments.add([]);
    _selectedIndex.add(0);
  }

  /// Closes previously opened document instance and removes it from
  /// opened documents list.
  Future<void> close(Document document) async {
    final opened = _openedDocuments.requireValue;
    final index = opened.indexWhere((doc) => doc.document == document);

    if (index != -1) {
      await opened.removeAt(index).document.close();

      final current = _selectedIndex.requireValue;
      if (current >= index) {
        _selectedIndex.add(current - 1);
      }

      _openedDocuments.add(List.of(opened));
    }
  }

  // Adds document to the list and notifies the stream
  Future<void> _addDocument(Document document) async {
    final currentDocs = _openedDocuments.requireValue;

    // Compute initial digest
    final digest = await _documentSaver.digest(document);

    _openedDocuments.add(
      List.of(currentDocs..add(DocumentDescriptor(document, digest, digest))),
    );

    if (!_selectedIndex.hasValue || _selectedIndex.requireValue == -1) {
      _selectedIndex.add(0);
    } else {
      _selectedIndex.add(currentDocs.length - 1);
    }
  }

  /// Saves the document using [DocumentSaver].
  /// Calls savePathChooser if [changePath] is `true` or current save path is
  /// not set
  Stream<DocumentSavingState> save(Document currentDocument,
      {bool changePath = false}) async* {
    yield DocumentSavingState.pickingSavePath;

    final savePath = await _getSavePath(currentDocument, changePath);

    if (savePath != null) {
      currentDocument.setSavePath(savePath);

      yield DocumentSavingState.saving;

      await currentDocument.save(_documentSaver);

      // Mark the document as saved
      final opened = _openedDocuments.value;
      if (opened != null) {
        final index =
            opened.indexWhere((element) => element.document == currentDocument);
        if (index != -1) {
          final current = opened[index];
          opened[index] = DocumentDescriptor(
            currentDocument,
            current.currentDigest,
            current.currentDigest,
          );

          _openedDocuments.add(List.of(opened));
        }
      }

      // Register file in the recent documents list
      _repositoryController.add(RecentDocumentInfo(path: savePath));
      await _repositoryController.commit();

      yield DocumentSavingState.saved;
    }
  }

  Future<File?> _getSavePath(Document document, bool changePath) async {
    final savePath = document.currentSavePath;

    if (savePath == null || changePath) {
      final chosen = await _savePathChooser.getFile(
        ExportFormat.native,
        document,
      );

      if (chosen != null) {
        return File(chosen);
      }
    }

    return savePath;
  }

  /// Updates current search filter text
  void setSearchText(String searchText) =>
      _documentFilter.setSearchText(searchText);
}

enum DocumentSavingState {
  pickingSavePath,
  saving,
  saved,
}
