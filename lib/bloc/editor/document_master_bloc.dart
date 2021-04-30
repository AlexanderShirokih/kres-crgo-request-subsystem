import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/editor/worksheet_creation_mode.dart';
import 'package:kres_requests2/data/editor/document_filter.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

part 'document_master_event.dart';

part 'document_master_state.dart';

/// BLoC that manages global state of the [Document]
class DocumentMasterBloc
    extends Bloc<DocumentMasterEvent, DocumentMasterState> {
  /// Function that returns document save path based on [Document] current
  /// working directory
  final Future<String?> Function(Document, String) savePathChooser;

  final Document _document;
  final DocumentSaver documentSaver;
  final DocumentFilter _documentFilter;

  /// Creates new [DocumentMasterBloc] instance for [document].
  DocumentMasterBloc(
    this._document, {
    required this.savePathChooser,
    required this.documentSaver,
  })  : _documentFilter = DocumentFilter(_document),
        super(WorksheetMasterIdleState(_document));

  @override
  Stream<DocumentMasterState> mapEventToState(
      DocumentMasterEvent event) async* {
    if (event is WorksheetMasterSaveEvent) {
      yield* _saveDocument(event.changePath, event.popAfterSave);
    } else if (event is WorksheetMasterAddNewWorksheetEvent) {
      yield* _createNewWorksheet(event.mode);
    } else if (event is WorksheetMasterWorksheetActionEvent) {
      yield* _handleWorksheetAction(event.targetWorksheet, event.action);
    } else if (event is WorksheetMasterSearchEvent) {
      yield* _toggleSearchMode(event);
    }
  }

  Stream<DocumentMasterState> _saveDocument(
      bool changePath, bool popAfterSave) async* {
    try {
      final pathChosen = await _saveDocument0(changePath, documentSaver);

      if (pathChosen) {
        yield WorksheetMasterSavingState(state.currentDocument,
            completed: false);

        await _document.save(documentSaver);

        yield WorksheetMasterSavingState(state.currentDocument,
            completed: true);
      }

      if (popAfterSave) {
        yield WorksheetMasterPopState(state.currentDocument);
      } else {
        yield WorksheetMasterIdleState(state.currentDocument);
      }
    } catch (e, s) {
      yield WorksheetMasterSavingState(
        state.currentDocument,
        error: e.toString(),
        stackTrace: s,
      );
    }
  }

  Future<bool> _saveDocument0(
    bool changePath,
    DocumentSaver documentSaver,
  ) async {
    final savePath = _document.currentSavePath;

    if (savePath == null || changePath) {
      final chosenSavePath =
          await savePathChooser(_document, _document.workingDirectory);

      if (chosenSavePath == null) return false;

      _document.setSavePath(
        path.extension(chosenSavePath) != '.json'
            ? File('$chosenSavePath.json')
            : File(chosenSavePath),
      );
    }

    return true;
  }

  Stream<DocumentMasterState> _createNewWorksheet(
      WorksheetCreationMode mode) async* {
    Map<String, dynamic> _buildArguments() => {
          'document': state.currentDocument,
          'workingDirectory': state.currentDocument.workingDirectory,
        };

    switch (mode) {
      case WorksheetCreationMode.import:
        await Modular.to.pushNamed(
          '/document/import/requests',
          arguments: _buildArguments(),
        );
        return;
      case WorksheetCreationMode.importCounters:
        await Modular.to.pushNamed(
          '/document/import/counters',
          arguments: _buildArguments(),
        );
        return;
      case WorksheetCreationMode.importNative:
        await Modular.to.pushNamed(
          '/document/open?pickPages=true',
          arguments: _buildArguments(),
        );
        return;
      case WorksheetCreationMode.empty:
        _document.makeActive(_document.addWorksheet().current);
        yield WorksheetMasterIdleState(_document);
    }
  }

  Stream<DocumentMasterState> _handleWorksheetAction(
      Worksheet targetWorksheet, WorksheetAction action) async* {
    switch (action) {
      case WorksheetAction.remove:
        await _document.removeWorksheet(targetWorksheet);
        break;
      case WorksheetAction.makeActive:
        _document.makeActive(targetWorksheet);
        break;
    }

    yield WorksheetMasterIdleState(_document);
  }

  Stream<DocumentMasterState> _toggleSearchMode(
      WorksheetMasterSearchEvent event) async* {
    _documentFilter.setSearchingTest(event.searchText ?? '');
  }
}
