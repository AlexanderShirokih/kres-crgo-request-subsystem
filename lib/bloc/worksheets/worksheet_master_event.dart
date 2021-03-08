part of 'worksheet_master_bloc.dart';

abstract class WorksheetMasterEvent extends Equatable {
  const WorksheetMasterEvent();
}

/// Event that used when user wants to save current document
/// [changePath] If `true` 'Save as' behaviour will be used.
/// [popAfterSave] If `true` that [WorksheetMasterPopState] will triggered
/// after file have saved.
class WorksheetMasterSaveEvent extends WorksheetMasterEvent {
  final bool changePath;
  final bool popAfterSave;

  const WorksheetMasterSaveEvent(
      {this.changePath = false, this.popAfterSave = false});

  @override
  List<Object> get props => [changePath];
}

class WorksheetMasterAddNewWorksheetEvent extends WorksheetMasterEvent {
  final WorksheetCreationMode mode;

  const WorksheetMasterAddNewWorksheetEvent(this.mode) : assert(mode != null);

  @override
  List<Object> get props => [mode];
}

class WorksheetMasterImportResultsEvent extends WorksheetMasterEvent {
  final Document importedDocument;

  const WorksheetMasterImportResultsEvent(this.importedDocument);

  @override
  List<Object> get props => [importedDocument];
}

class WorksheetMasterRefreshDocumentStateEvent extends WorksheetMasterEvent {
  @override
  List<Object> get props => [];
}

class WorksheetMasterSearchEvent extends WorksheetMasterEvent {
  final String? searchText;

  WorksheetMasterSearchEvent([this.searchText]);

  @override
  List<Object?> get props => [searchText];
}

enum WorksheetAction { remove, makeActive }

class WorksheetMasterWorksheetActionEvent extends WorksheetMasterEvent {
  final Worksheet targetWorksheet;
  final WorksheetAction action;

  const WorksheetMasterWorksheetActionEvent(this.targetWorksheet, this.action);

  @override
  List<Object> get props => [targetWorksheet, action];
}
