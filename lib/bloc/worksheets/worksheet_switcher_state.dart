part of 'worksheet_switcher_bloc.dart';

abstract class WorksheetSwitcherState extends Equatable {
  const WorksheetSwitcherState();
}

/// Initial state without any data
class WorksheetSwitcherInitial extends WorksheetSwitcherState {
  @override
  List<Object> get props => [];
}

/// Shows a list of worksheets
class WorksheetSwitcherShowWorksheets extends WorksheetSwitcherState {
  final List<RequestSet> worksheets;
  final RequestSet active;

  WorksheetSwitcherShowWorksheets(this.worksheets, this.active)
      : assert(worksheets != null),
        assert(active != null);

  @override
  List<Object> get props => [worksheets, active];
}
