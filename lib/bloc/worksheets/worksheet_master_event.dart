part of 'worksheet_master_bloc.dart';

/// Base abstract event for [WorksheetMasterBloc]
@sealed
abstract class WorksheetMasterEvent extends Equatable {
  const WorksheetMasterEvent._();
}

/// Event that used when user wants to save current document.
class WorksheetMasterSaveEvent extends WorksheetMasterEvent {
  /// If `true` 'Save as' behaviour will be used.
  final bool changePath;

  /// If [popAfterSave] is `true` that [WorksheetMasterPopState] will be
  /// triggered after file have saved.
  final bool popAfterSave;

  const WorksheetMasterSaveEvent(
      {this.changePath = false, this.popAfterSave = false})
      : super._();

  @override
  List<Object> get props => [changePath, popAfterSave];
}

/// Used to add a page (worksheet) and optionally open importer wizard
class WorksheetMasterAddNewWorksheetEvent extends WorksheetMasterEvent {
  final WorksheetCreationMode mode;

  const WorksheetMasterAddNewWorksheetEvent(this.mode) : super._();

  @override
  List<Object> get props => [mode];
}

/// Used to push results of importer wizard to the current document
class WorksheetMasterImportResultsEvent extends WorksheetMasterEvent {
  /// New instance of the document with imported data to be merged with the
  /// current document.
  final Document importedDocument;

  const WorksheetMasterImportResultsEvent(this.importedDocument) : super._();

  @override
  List<Object> get props => [importedDocument];
}

/// TODO: Deprecated event?
/// Event used to build UI when document was changed
class WorksheetMasterRefreshDocumentStateEvent extends WorksheetMasterEvent {
  const WorksheetMasterRefreshDocumentStateEvent() : super._();

  @override
  List<Object> get props => [];
}

/// Event used to toggle searching mode with some searching text
/// If [searchText] is `null` search mode will be disabled
class WorksheetMasterSearchEvent extends WorksheetMasterEvent {
  final String? searchText;

  const WorksheetMasterSearchEvent([this.searchText]) : super._();

  @override
  List<Object?> get props => [searchText];
}

/// Action that defined what to do with the selected worksheet
enum WorksheetAction {
  /// Removes worksheet from the current document
  remove,

  /// Makes target worksheet active on the current document
  makeActive,
}

/// Initiates an action on the target worksheet
class WorksheetMasterWorksheetActionEvent extends WorksheetMasterEvent {
  /// Selected worksheet
  final Worksheet targetWorksheet;

  ///  Action to be done on selected worksheet
  final WorksheetAction action;

  const WorksheetMasterWorksheetActionEvent(this.targetWorksheet, this.action)
      : super._();

  @override
  List<Object> get props => [targetWorksheet, action];
}
