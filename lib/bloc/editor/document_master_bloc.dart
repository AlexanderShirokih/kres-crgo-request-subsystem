import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/editor/worksheet_creation_mode.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/domain/service/document_service.dart';
import 'package:meta/meta.dart';

part 'document_master_event.dart';
part 'document_master_state.dart';

/// BLoC that manages global state of the [Document]
class DocumentMasterBloc
    extends Bloc<DocumentMasterEvent, DocumentMasterState> {
  /// Service for handling actions on worksheet
  final DocumentService _service;

  /// Navigator for navigating
  final IModularNavigator _navigator;

  /// Creates new [DocumentMasterBloc] instance for [document].
  DocumentMasterBloc(this._service, this._navigator)
      : super(WorksheetMasterIdleState(_service.document));

  @override
  Stream<DocumentMasterState> mapEventToState(
      DocumentMasterEvent event) async* {
    if (event is SaveEvent) {
      yield* _saveDocument(event.changePath, event.popAfterSave);
    } else if (event is AddNewWorksheetEvent) {
      yield* _createNewWorksheet(event.mode);
    } else if (event is WorksheetActionEvent) {
      yield* _handleWorksheetAction(event.targetWorksheet, event.action);
    } else if (event is WorksheetMasterSearchEvent) {
      yield* _toggleSearchMode(event);
    }
  }

  Stream<DocumentMasterState> _saveDocument(
      bool changePath, bool popAfterSave) async* {
    try {
      await for (final saveState in _service.saveDocument(changePath)) {
        switch (saveState) {
          case DocumentSavingState.pickingSavePath:
            break;
          case DocumentSavingState.saving:
            yield WorksheetMasterSavingState(state.currentDocument,
                completed: false);
            break;
          case DocumentSavingState.saved:
            yield WorksheetMasterSavingState(state.currentDocument,
                completed: true);
            break;
        }
      }

      if (popAfterSave) {
        _navigator.pop();
      } else {
        yield WorksheetMasterIdleState(state.currentDocument);
      }
    } catch (e, s) {
      yield WorksheetMasterSavingState(
        state.currentDocument,
        error: e.toString(),
        stackTrace: s,
      );
      yield WorksheetMasterIdleState(state.currentDocument);
    }
  }

  Stream<DocumentMasterState> _createNewWorksheet(
      WorksheetCreationMode mode) async* {
    Map<String, dynamic> _buildArguments() => {
          'document': state.currentDocument,
          'workingDirectory': state.currentDocument.workingDirectory,
        };

    switch (mode) {
      case WorksheetCreationMode.import:
        await _navigator.pushNamed(
          '/document/import/requests',
          arguments: _buildArguments(),
        );
        return;
      case WorksheetCreationMode.importCounters:
        await _navigator.pushNamed(
          '/document/import/counters',
          arguments: _buildArguments(),
        );
        return;
      case WorksheetCreationMode.importNative:
        await _navigator.pushNamed(
          '/document/open?pickPages=true',
          arguments: _buildArguments(),
        );
        return;
      case WorksheetCreationMode.empty:
        _service.addEmptyWorksheet();
    }
  }

  Stream<DocumentMasterState> _handleWorksheetAction(
      Worksheet targetWorksheet, WorksheetAction action) async* {
    switch (action) {
      case WorksheetAction.remove:
        _service.removeWorksheet(targetWorksheet);
        break;
      case WorksheetAction.makeActive:
        _service.makeActive(targetWorksheet);
        break;
    }

    yield WorksheetMasterIdleState(_service.document);
  }

  Stream<DocumentMasterState> _toggleSearchMode(
      WorksheetMasterSearchEvent event) async* {
    _service.setSearchFilter(event.searchText ?? '');
  }
}
