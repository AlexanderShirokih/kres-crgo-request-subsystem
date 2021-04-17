import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/bloc/worksheets/worksheet_creation_mode.dart';
import 'package:kres_requests2/data/editor/document_filter.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/optional_data.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:meta/meta.dart';

part 'worksheet_master_event.dart';
part 'worksheet_master_state.dart';

/// BLoC that manages global state of the [Document]
class WorksheetMasterBloc
    extends Bloc<WorksheetMasterEvent, WorksheetMasterState> {
  /// Function that returns document save path based on [Document] current
  /// working directory
  final Future<String?> Function(Document, String) savePathChooser;

  final Document _document;
  final DocumentFilter _documentFilter;

  /// Creates new [WorksheetMasterBloc] instance for [document].
  WorksheetMasterBloc(this._document, {required this.savePathChooser})
      : _documentFilter = DocumentFilter(_document),
        super(WorksheetMasterIdleState(_document));

  @override
  Stream<WorksheetMasterState> mapEventToState(
      WorksheetMasterEvent event) async* {
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

  Stream<WorksheetMasterState> _saveDocument(
      bool changePath, bool popAfterSave) async* {
    try {
      yield WorksheetMasterSavingState(state.currentDocument, completed: false);

      final wasSaved =
          await _document.saveDocument(changePath, savePathChooser);

      if (wasSaved) {
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
        error: ErrorWrapper(e, s),
      );
    }
  }

  Stream<WorksheetMasterState> _createNewWorksheet(
      WorksheetCreationMode mode) async* {
    switch (mode) {
      case WorksheetCreationMode.import:
        yield WorksheetMasterShowImporterState(
          state.currentDocument,
          WorksheetImporterType.requestsImporter,
        );
        return;
      case WorksheetCreationMode.importCounters:
        yield WorksheetMasterShowImporterState(
          state.currentDocument,
          WorksheetImporterType.countersImporter,
        );
        return;
      case WorksheetCreationMode.importNative:
        yield WorksheetMasterShowImporterState(
          state.currentDocument,
          WorksheetImporterType.nativeImporter,
        );
        return;
      case WorksheetCreationMode.empty:
        _document.makeActive(_document.addWorksheet().current);
        yield WorksheetMasterIdleState(_document);
    }
  }

  Stream<WorksheetMasterState> _handleWorksheetAction(
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

  Stream<WorksheetMasterState> _toggleSearchMode(
      WorksheetMasterSearchEvent event) async* {
    _documentFilter.setSearchingTest(event.searchText ?? '');
  }
}
