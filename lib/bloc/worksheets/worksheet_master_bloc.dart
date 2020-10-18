import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/bloc/worksheets/worksheet_creation_mode.dart';
import 'package:kres_requests2/models/optional_data.dart';
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
    if (event is WorksheetMasterEventSave) {
      yield* _saveDocument(event.changePath, event.popAfterSave);
    } else if (event is WorksheetMasterAddNewWorksheetEvent) {
      yield* _createNewWorksheet(event.mode);
    } else if (event is WorksheetMasterImportResultsEvent) {
      yield* _handleImporterResult(event.importedDocument);
    } else if (event is WorksheetMasterWorksheetActionEvent) {
      yield* _handleWorksheetAction(event.targetWorksheet, event.action);
    } else if (event is WorksheetMasterRefreshDocumentStateEvent) {
      yield WorksheetMasterIdleState(
          state.currentDocument, state.currentDirectory);
    }
  }

  Stream<WorksheetMasterState> _saveDocument(bool changePath,
      bool popAfterSave) async* {
    var currentDirectory = state.currentDirectory;
    if (state.currentDocument.savePath == null || changePath) {
      final savePath = await savePathChooser(
          state.currentDocument, state.currentDirectory);
      if (savePath == null) return;
      currentDirectory = path.dirname(savePath);

      state.currentDocument.savePath = path.extension(savePath) != '.json'
          ? File('$savePath.json')
          : File(savePath);
    }

    try {
      yield WorksheetMasterSavingState(
          state.currentDocument, currentDirectory, saved: false);
      await state.currentDocument.save();
      yield WorksheetMasterSavingState(
          state.currentDocument, currentDirectory, saved: true);

      if (popAfterSave) {
        yield WorksheetMasterPopState(state.currentDocument, currentDirectory);
      } else {
        yield WorksheetMasterIdleState(state.currentDocument, currentDirectory);
      }
    } catch (e, s) {
      yield WorksheetMasterSavingState(
        state.currentDocument, currentDirectory,
        error: ErrorWrapper(e.toString(), s.toString()),
      );
    }
  }

  Stream<WorksheetMasterState> _createNewWorksheet(
      WorksheetCreationMode mode) async* {
    switch (mode) {
      case WorksheetCreationMode.Import:
        yield WorksheetMasterShowImporterState(
          state.currentDocument, state.currentDirectory,
          WorksheetImporterType.requestsImporter,
        );
        return;
      case WorksheetCreationMode.ImportCounters:
        yield WorksheetMasterShowImporterState(
          state.currentDocument, state.currentDirectory,
          WorksheetImporterType.countersImporter,
        );
        return;
      case WorksheetCreationMode.ImportNative:
        yield WorksheetMasterShowImporterState(
          state.currentDocument, state.currentDirectory,
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
          state.currentDocument, state.currentDirectory,);
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
      state.currentDocument, state.currentDirectory,);
  }
}
