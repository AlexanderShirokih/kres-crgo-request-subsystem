part of 'document_bloc.dart';

/// Base event class for [DocumentBloc]
@sealed
abstract class DocumentEvent extends Equatable {
  const DocumentEvent._();
}

/// Action that defined what to do with the selected worksheet
enum WorksheetAction {
  /// Removes worksheet from the current document
  remove,

  /// Makes target worksheet active on the current document
  makeActive,
}

/// Initiates the action on the target worksheet
class WorksheetActionEvent extends DocumentEvent {
  /// Selected worksheet
  final Worksheet targetWorksheet;

  ///  Action to be done on selected worksheet
  final WorksheetAction action;

  const WorksheetActionEvent(this.targetWorksheet, this.action) : super._();

  @override
  List<Object> get props => [targetWorksheet, action];
}

/// Used to add a page (worksheet) and optionally open importer wizard
class AddNewWorksheetEvent extends DocumentEvent {
  final WorksheetCreationMode mode;

  const AddNewWorksheetEvent(this.mode) : super._();

  @override
  List<Object> get props => [mode];
}

/// Event used internally to update view when document state changes
class _UpdateDocumentInfo extends DocumentEvent {
  final DocumentInfo info;

  const _UpdateDocumentInfo(this.info) : super._();

  @override
  List<Object?> get props => [info];
}
