part of 'worksheet_bloc.dart';

/// Base event class for [WorksheetBloc]
@sealed
abstract class WorksheetEvent extends Equatable {
  const WorksheetEvent._();
}

/// Sends signal to swap two requests in the list
class SwapRequestsEvent extends WorksheetEvent {
  final Request from;
  final Request to;

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
class RequestSelectionEvent extends WorksheetEvent {
  /// Target request to do action on it.
  /// Required for [SelectionAction.begin], [SelectionAction.add] and
  /// [SelectionAction.remove] actions
  final Request? target;

  /// Specified what we should do with the current selection
  final SelectionAction action;

  const RequestSelectionEvent(this.action, [this.target]) : super._();

  @override
  List<Object?> get props => [target, action];
}

/// Updates group associated with the request
class ChangeGroupEvent extends WorksheetEvent {
  final Request target;
  final int newGroup;

  const ChangeGroupEvent(this.target, this.newGroup) : super._();

  @override
  List<Object?> get props => [newGroup, target];
}

/// Used to trigger state update when worksheet changes
class SetCurrentWorksheetEvent extends WorksheetEvent {
  final Worksheet worksheet;
  final List<Request>? filtered;

  const SetCurrentWorksheetEvent(this.worksheet, [this.filtered]) : super._();

  @override
  List<Object?> get props => [worksheet, filtered];
}

/// Event used to edit existing request or create a new request
class EditRequestEvent extends WorksheetEvent {
  /// Request to edit
  final Request? request;

  const EditRequestEvent([this.request]) : super._();

  @override
  List<Object?> get props => [request];
}
