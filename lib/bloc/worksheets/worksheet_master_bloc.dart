import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:kres_requests2/repo/document_repository.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/bloc/worksheets/worksheet_creation_mode.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/models/document.dart';

part 'worksheet_master_event.dart';

part 'worksheet_master_state.dart';

// TODO: Delegate Document modification logic to DocumentRepository
class WorksheetMasterBloc
    extends Bloc<WorksheetMasterEvent, WorksheetMasterState> {
  final Future<String> Function(Document, String) savePathChooser;

  WorksheetMasterBloc(Document document, {@required this.savePathChooser})
      : assert(savePathChooser != null),
        super(
          WorksheetMasterIdleState(
              DocumentRepository(document ??= Document.empty())
                ..currentDirectory = (document?.savePath == null
                    ? './'
                    : path.dirname(document.savePath.path))),
        );

  @override
  Future<Function> close() {
    state.documentRepository.close();
    return super.close();
  }

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
          () => _handleWorksheetAction(event.targetWorksheet, event.action));
    } else if (event is WorksheetMasterSearchEvent) {
      yield* _toggleSearchMode(event);
    } else if (event is WorksheetMasterRefreshDocumentStateEvent) {
      yield* _keepSearchingState(
          () => Stream.value(WorksheetMasterIdleState(
              state.documentRepository..rebuildRequests())),
          rebuildSearch: true);
    }
  }

  Stream<WorksheetMasterState> _keepSearchingState(
      Stream<WorksheetMasterState> Function() scope,
      {bool rebuildSearch = false}) async* {
    if (state is WorksheetMasterSearchingState) {
      final searchState = state as WorksheetMasterSearchingState;
      final searchText = searchState.searchText;
      yield* scope();

      if (rebuildSearch)
        add(WorksheetMasterSearchEvent(searchText));
      else
        yield WorksheetMasterSearchingState(
          state.documentRepository,
          searchText: searchText,
        );
    } else {
      yield* scope();
      yield WorksheetMasterIdleState(state.documentRepository);
    }
  }

  Stream<WorksheetMasterState> _saveDocument(
      bool changePath, bool popAfterSave) async* {
    var currentDirectory = state.documentRepository.currentDirectory;
    if (state.documentRepository.document.savePath == null || changePath) {
      final savePath = await savePathChooser(
          state.documentRepository.document, currentDirectory);
      if (savePath == null) return;
      currentDirectory = path.dirname(savePath);

      state.documentRepository.documentSavePath = savePath;
    }

    try {
      state.documentRepository.currentDirectory = currentDirectory;
      yield WorksheetMasterSavingState(state.documentRepository,
          completed: false);
      await state.documentRepository.save();
      yield WorksheetMasterSavingState(state.documentRepository,
          completed: true);

      if (popAfterSave) {
        yield WorksheetMasterPopState(state.documentRepository);
      } else {
        yield WorksheetMasterIdleState(state.documentRepository);
      }
    } catch (e, s) {
      yield WorksheetMasterSavingState(
        state.documentRepository,
        error: ErrorWrapper(e.toString(), s.toString()),
      );
    }
  }

  Stream<WorksheetMasterState> _createNewWorksheet(
      WorksheetCreationMode mode) async* {
    switch (mode) {
      case WorksheetCreationMode.Import:
        yield WorksheetMasterShowImporterState(
          state.documentRepository,
          WorksheetImporterType.requestsImporter,
        );
        return;
      case WorksheetCreationMode.ImportCounters:
        yield WorksheetMasterShowImporterState(
          state.documentRepository,
          WorksheetImporterType.countersImporter,
        );
        return;
      case WorksheetCreationMode.ImportNative:
        yield WorksheetMasterShowImporterState(
          state.documentRepository,
          WorksheetImporterType.nativeImporter,
        );
        return;
      case WorksheetCreationMode.Empty:
      default:
        state.documentRepository.addEmptyWorksheet();
        yield WorksheetMasterIdleState(state.documentRepository);
    }
  }

  Stream<WorksheetMasterState> _handleImporterResult(
      Document importedDocument) async* {
    if (importedDocument != null) {
      importedDocument.active = importedDocument.worksheets.last;

      final isIdentical =
          identical(state.documentRepository.document, importedDocument);

      if (isIdentical) {
        yield WorksheetMasterIdleState(
            state.documentRepository..rebuildRequests());
      } else {
        state.documentRepository.close();
        yield WorksheetMasterIdleState(DocumentRepository(importedDocument)
          ..currentDirectory = state.documentRepository.currentDirectory);
      }
    }
  }

  Stream<WorksheetMasterState> _handleWorksheetAction(
      Worksheet targetWorksheet, WorksheetAction action) async* {
    switch (action) {
      case WorksheetAction.remove:
        state.documentRepository.removeWorksheet(targetWorksheet);
        break;
      case WorksheetAction.makeActive:
        state.documentRepository.active = targetWorksheet;
        break;
    }

    yield WorksheetMasterIdleState(state.documentRepository);
  }

  Stream<WorksheetMasterState> _toggleSearchMode(
      WorksheetMasterSearchEvent event) async* {
    state.documentRepository.setFilter(event.searchText);

    if (state is WorksheetMasterSearchingState && event.searchText == null) {
      yield WorksheetMasterIdleState(state.documentRepository);
    } else {
      yield WorksheetMasterSearchingState(
        state.documentRepository,
        searchText: event.searchText,
      );
    }
  }
}
