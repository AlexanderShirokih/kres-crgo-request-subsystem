part of 'worksheet_switcher_bloc.dart';

abstract class WorksheetSwitcherEvent extends Equatable {
  const WorksheetSwitcherEvent();
}

/// Fetches an actual list of worksheets
class WorksheetSwitcherFetchEvent extends WorksheetSwitcherEvent {
  const WorksheetSwitcherFetchEvent();

  @override
  List<Object> get props => [];
}

/// Sets the currently active worksheet
class WorksheetSwitcherSetActiveEvent extends WorksheetSwitcherEvent {
  final RequestSet active;

  const WorksheetSwitcherSetActiveEvent(this.active) : assert(active != null);

  @override
  List<Object> get props => [active];
}

/// Removes worksheet from the document
class WorksheetSwitcherRemoveEvent extends WorksheetSwitcherEvent {
  final RequestSet target;

  const WorksheetSwitcherRemoveEvent(this.target) : assert(target != null);

  @override
  List<Object> get props => [target];
}

/// Adds a new worksheet to the document
class WorksheetSwitcherAddNewEvent extends WorksheetSwitcherEvent {
  const WorksheetSwitcherAddNewEvent();

  @override
  List<Object> get props => [];
}

/// Adds a new worksheet to the document
class WorksheetSwitcherRenameEvent extends WorksheetSwitcherEvent {
  final RequestSet target;
  final String newName;

  const WorksheetSwitcherRenameEvent(this.target, this.newName)
      : assert(target != null),
        assert(newName != null);

  @override
  List<Object> get props => [target, newName];
}
