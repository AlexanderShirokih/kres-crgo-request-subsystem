import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/bloc/worksheets/worksheet_creation_mode.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/models/document.dart';

part 'worksheet_master_event.dart';

part 'worksheet_master_state.dart';

class WorksheetMasterBloc
    extends Bloc<WorksheetMasterEvent, WorksheetMasterState> {
  final Future<String> Function(Document, String) savePathChooser;

  WorksheetMasterBloc(Document document, {@required this.savePathChooser})
      : assert(savePathChooser != null),
        super(
        WorksheetMasterIdleState(
            document ??= Document.empty(),
            (document?.savePath == null
                ? './'
                : path.dirname(document.savePath.path))),
      );

  @override
  Stream<WorksheetMasterState> mapEventToState(
      WorksheetMasterEvent event) async* {
    if (event is WorksheetMasterSaveEvent) {
      yield* _keepSearchingState(
              () => _saveDocument(event.changePath, event.popAfterSave));
    } else if (event is WorksheetMasterAddNewWorksheetEvent) {
      yield* _createNewWorksheet(event.mode);
    } else if (event is WorksheetMasterImportResultsEvent) {
      yield* _handleImporterResult(event.importedDocument);
    } else if (event is WorksheetMasterWorksheetActionEvent) {
      yield* _keepSearchingState(
              () =>
              _handleWorksheetAction(event.targetWorksheet, event.action));
    } else if (event is WorksheetMasterSearchEvent) {
      yield* _toggleSearchMode(event);
    } else if (event is WorksheetMasterRefreshDocumentStateEvent) {
      yield* _keepSearchingState(() =>
          Stream.value(WorksheetMasterIdleState(
              state.currentDocument, state.currentDirectory)),
          rebuildSearch: true);
    }
  }

  Stream<WorksheetMasterState> _keepSearchingState(
      Stream<WorksheetMasterState> Function() scope,
      {bool rebuildSearch = false}) async* {
    if (state is WorksheetMasterSearchingState) {
      final searchState = state as WorksheetMasterSearchingState;
      final filtered = searchState.filteredItems;
      yield* scope();

      if (rebuildSearch)
        add(searchState.sourceEvent);
      else
        yield WorksheetMasterSearchingState(
          state.currentDocument,
          state.currentDirectory,
          filteredItems: filtered,
          sourceEvent: (state as WorksheetMasterSearchingState).sourceEvent,
        );
    } else {
      yield* scope();
      yield WorksheetMasterIdleState(
          state.currentDocument, state.currentDirectory);
    }
  }

  Stream<WorksheetMasterState> _saveDocument(bool changePath,
      bool popAfterSave) async* {
    var currentDirectory = state.currentDirectory;
    if (state.currentDocument.savePath == null || changePath) {
      final savePath =
      await savePathChooser(state.currentDocument, state.currentDirectory);
      if (savePath == null) return;
      currentDirectory = path.dirname(savePath);

      state.currentDocument.savePath = path.extension(savePath) != '.json'
          ? File('$savePath.json')
          : File(savePath);
    }

    try {
      yield WorksheetMasterSavingState(state.currentDocument, currentDirectory,
          completed: false);
      await state.currentDocument.save();
      yield WorksheetMasterSavingState(state.currentDocument, currentDirectory,
          completed: true);

      if (popAfterSave) {
        yield WorksheetMasterPopState(state.currentDocument, currentDirectory);
      } else {
        yield WorksheetMasterIdleState(state.currentDocument, currentDirectory);
      }
    } catch (e, s) {
      yield WorksheetMasterSavingState(
        state.currentDocument,
        currentDirectory,
        error: ErrorWrapper(e.toString(), s.toString()),
      );
    }
  }

  Stream<WorksheetMasterState> _createNewWorksheet(
      WorksheetCreationMode mode) async* {
    switch (mode) {
      case WorksheetCreationMode.Import:
        yield WorksheetMasterShowImporterState(
          state.currentDocument,
          state.currentDirectory,
          WorksheetImporterType.requestsImporter,
        );
        return;
      case WorksheetCreationMode.ImportCounters:
        yield WorksheetMasterShowImporterState(
          state.currentDocument,
          state.currentDirectory,
          WorksheetImporterType.countersImporter,
        );
        return;
      case WorksheetCreationMode.ImportNative:
        yield WorksheetMasterShowImporterState(
          state.currentDocument,
          state.currentDirectory,
          WorksheetImporterType.nativeImporter,
        );
        return;
    // TODO: Implement feature
      case WorksheetCreationMode.EmptyRaid:
      case WorksheetCreationMode.Empty:
      default:
        state.currentDocument.active =
            state.currentDocument.addEmptyWorksheet();
        yield WorksheetMasterIdleState(
          state.currentDocument,
          state.currentDirectory,
        );
    }
  }

  Stream<WorksheetMasterState> _handleImporterResult(
      Document importedDocument) async* {
    if (importedDocument != null) {
      importedDocument.active = importedDocument.worksheets.last;
      yield WorksheetMasterIdleState(importedDocument, state.currentDirectory);
    }
  }

  Stream<WorksheetMasterState> _handleWorksheetAction(Worksheet targetWorksheet,
      WorksheetAction action) async* {
    switch (action) {
      case WorksheetAction.remove:
        state.currentDocument.removeWorksheet(targetWorksheet);
        break;
      case WorksheetAction.makeActive:
        state.currentDocument.active = targetWorksheet;
        break;
    }

    yield WorksheetMasterIdleState(
        state.currentDocument, state.currentDirectory);
  }

  Stream<WorksheetMasterState> _toggleSearchMode(
      WorksheetMasterSearchEvent event) async* {
    if (state is WorksheetMasterSearchingState && event.searchText == null)
      yield WorksheetMasterIdleState(
          state.currentDocument, state.currentDirectory);
    else {
      final filtered = _filterRequests(state.currentDocument, event.searchText);

      yield WorksheetMasterSearchingState(
        state.currentDocument,
        state.currentDirectory,
        filteredItems: filtered,
        sourceEvent: event,
      );
    }
  }

  // TODO: Create a sort of DocumentRepository and move this method to it
  Map<Worksheet, List<RequestEntity>> _filterRequests(Document document,
      String searchText) {
    if (searchText == null || searchText.isEmpty)
      return <Worksheet, List<RequestEntity>>{};
    searchText = searchText.toLowerCase();

    return Map.fromIterable(document.worksheets,
        key: (worksheet) => worksheet,
        value: (worksheet) =>
            worksheet.requests.where((RequestEntity request) {
              return (request.accountId?.toString()?.padLeft(6, '0') ?? '')
                  .contains(searchText) ||
                  request.name.toLowerCase().contains(searchText) ||
                  request.address.toLowerCase().contains(searchText) ||
                  request.counterInfo.toLowerCase().contains(searchText) ||
                  request.additionalInfo.toLowerCase().contains(searchText);
            }).toList());
  }
}
