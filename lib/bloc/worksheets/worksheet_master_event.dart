part of 'worksheet_master_bloc.dart';

abstract class WorksheetMasterEvent extends Equatable {
  const WorksheetMasterEvent();
}

class WorksheetMasterAddNewWorksheetEvent extends WorksheetMasterEvent {
  final WorksheetCreationMode mode;

  const WorksheetMasterAddNewWorksheetEvent(this.mode) : assert(mode != null);

  @override
  List<Object> get props => [mode];
}

class WorksheetMasterRefreshDocumentStateEvent extends WorksheetMasterEvent {
  @override
  List<Object> get props => [];
}

class WorksheetMasterSearchEvent extends WorksheetMasterEvent {
  final String searchText;

  WorksheetMasterSearchEvent([this.searchText]);

  @override
  List<Object> get props => [searchText];
}

enum WorksheetAction { remove, makeActive }

class WorksheetMasterWorksheetActionEvent extends WorksheetMasterEvent {
  final RequestSet targetWorksheet;
  final WorksheetAction action;

  const WorksheetMasterWorksheetActionEvent(this.targetWorksheet, this.action);

  @override
  List<Object> get props => [targetWorksheet, action];
}
