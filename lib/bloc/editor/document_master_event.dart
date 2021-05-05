part of 'document_master_bloc.dart';

/// Base abstract event for [DocumentMasterBloc]
@sealed
abstract class DocumentMasterEvent extends Equatable {
  const DocumentMasterEvent._();
}

/// Event that used when user wants to save current document.
class WorksheetMasterSaveEvent extends DocumentMasterEvent {
  /// If `true` 'Save as' behaviour will be used.
  final bool changePath;

  /// If [popAfterSave] is `true` that the page will popped after file have saved.
  final bool popAfterSave;

  const WorksheetMasterSaveEvent(
      {this.changePath = false, this.popAfterSave = false})
      : super._();

  @override
  List<Object> get props => [changePath, popAfterSave];
}

/// Used to add a page (worksheet) and optionally open importer wizard
class WorksheetMasterAddNewWorksheetEvent extends DocumentMasterEvent {
  final WorksheetCreationMode mode;

  const WorksheetMasterAddNewWorksheetEvent(this.mode) : super._();

  @override
  List<Object> get props => [mode];
}

/// Event used to toggle searching mode with some searching text
/// If [searchText] is `null` search mode will be disabled
class WorksheetMasterSearchEvent extends DocumentMasterEvent {
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
class WorksheetMasterWorksheetActionEvent extends DocumentMasterEvent {
  /// Selected worksheet
  final Worksheet targetWorksheet;

  ///  Action to be done on selected worksheet
  final WorksheetAction action;

  const WorksheetMasterWorksheetActionEvent(this.targetWorksheet, this.action)
      : super._();

  @override
  List<Object> get props => [targetWorksheet, action];
}
