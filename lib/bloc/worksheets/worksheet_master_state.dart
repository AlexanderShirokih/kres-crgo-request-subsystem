part of 'worksheet_master_bloc.dart';

/// Common state class for `WorksheetMasterScreen`
abstract class WorksheetMasterState extends Equatable {
  const WorksheetMasterState();

  @override
  List<Object> get props => [];
}

/// State used when some data is loading
class WorksheetFetchingState extends WorksheetMasterState {
  const WorksheetFetchingState();
}

/// State that indicates an error during communication with API
class WorksheetErrorState extends WorksheetMasterState {
  final ErrorWrapper error;

  const WorksheetErrorState(this.error);
}

class WorksheetMasterPopState extends WorksheetMasterState {
  const WorksheetMasterPopState();
}

/// State when no active actions in use
class WorksheetMasterIdleState extends WorksheetMasterState {
  final RequestSet currentEditable;

  const WorksheetMasterIdleState(this.currentEditable)
      : assert(currentEditable != null);
}

enum WorksheetImporterType {
  requestsImporter,
  countersImporter,
}

class WorksheetMasterShowImporterState extends WorksheetMasterState {
  final WorksheetImporterType importerType;

  const WorksheetMasterShowImporterState(
    this.importerType,
  );

  @override
  List<Object> get props => [importerType];
}

class WorksheetMasterSearchingState extends WorksheetMasterState {
  final WorksheetMasterSearchEvent sourceEvent;
  final Map<RequestSet, List<Request>> filteredItems;
  final RequestSet active;

  const WorksheetMasterSearchingState({
    @required this.sourceEvent,
    @required this.filteredItems,
    @required this.active,
  })  : assert(sourceEvent != null),
        assert(filteredItems != null),
        assert(active != null);

  @override
  List<Object> get props => [filteredItems, sourceEvent, active];
}
