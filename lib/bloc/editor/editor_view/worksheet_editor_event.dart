part of 'worksheet_editor_bloc.dart';

/// Base event class for [WorksheetEditorBloc]
@sealed
abstract class WorksheetEditorEvent extends Equatable {
  const WorksheetEditorEvent._();
}

/// Sends signal to swap two requests in the list
class SwapRequestsEvent extends WorksheetEditorEvent {
  final RequestEntity from;
  final RequestEntity to;

  const SwapRequestsEvent({required this.from, required this.to}) : super._();

  @override
  List<Object?> get props => [from, to];
}

enum SelectionAction {
  /// Enters the selection mode with single item
  begin,

  /// Adds target request to the selection
  add,

  /// Removes target request from the selection
  remove,

  /// Cancels the selection mode
  cancel,

  /// Adds all items to the selection list
  selectAll,

  /// Adds all items with common group index where (groupIndex !=0) to selection
  /// list
  selectSingleGroup,

  /// Deletes selected requests from the worksheet and cancels selection mode
  dropSelected,
}

/// Used to manage request list selections
class RequestSelectionEvent extends WorksheetEditorEvent {
  /// Target request to do action on it.
  /// Required for [SelectionAction.begin], [SelectionAction.add] and
  /// [SelectionAction.remove] actions
  final RequestEntity? target;

  /// Specified what we should do with the current selection
  final SelectionAction action;

  const RequestSelectionEvent(this.action, [this.target]) : super._();

  @override
  List<Object?> get props => [target, action];
}

/// Updates group associated with the request
class ChangeGroupEvent extends WorksheetEditorEvent {
  final RequestEntity target;
  final int newGroup;

  const ChangeGroupEvent(this.target, this.newGroup) : super._();

  @override
  List<Object?> get props => [newGroup, target];
}

/// Used internally to trigger state update when worksheet changes
class _UpdateWorksheetStateEvent extends WorksheetEditorEvent {
  final Worksheet worksheet;

  const _UpdateWorksheetStateEvent(this.worksheet) : super._();

  @override
  List<Object?> get props => [worksheet];
}