import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:kres_requests2/domain/document_service.dart';
import 'package:kres_requests2/domain/request_set_service.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/models/request.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/bloc/worksheets/worksheet_creation_mode.dart';
import 'package:kres_requests2/models/request_set.dart';

part 'worksheet_master_event.dart';

part 'worksheet_master_state.dart';

class WorksheetMasterBloc
    extends Bloc<WorksheetMasterEvent, WorksheetMasterState> {
  final DocumentService _documentService;

  WorksheetMasterBloc(DocumentService documentService)
      : assert(documentService != null),
        _documentService = documentService,
        super(WorksheetMasterIdleState(documentService.getActive()));

  @override
  Stream<WorksheetMasterState> mapEventToState(
      WorksheetMasterEvent event) async* {
    if (event is WorksheetMasterAddNewWorksheetEvent) {
      yield* _createNewWorksheet(event.mode);
    } else if (event is WorksheetMasterWorksheetActionEvent) {
      yield* _keepSearchingState(
          () => _handleWorksheetAction(event.targetWorksheet, event.action));
    } else if (event is WorksheetMasterSearchEvent) {
      yield* _toggleSearchMode(event);
    } else if (event is WorksheetMasterRefreshDocumentStateEvent) {
      yield* _keepSearchingState(
          () => Stream.value(
              WorksheetMasterIdleState(_documentService.getActive())),
          rebuildSearch: true);
    }
  }

  Stream<WorksheetMasterState> _safeApiCall(
          Stream<WorksheetMasterState> Function() action) =>
      action().transform(StreamTransformer<WorksheetMasterState,
          WorksheetMasterState>.fromHandlers(
        handleError: (e, s, sink) {
          sink.add(
              WorksheetErrorState(ErrorWrapper(e.toString(), s.toString())));
        },
      ));

  Stream<WorksheetMasterState> _keepSearchingState(
      Stream<WorksheetMasterState> Function() scope,
      {bool rebuildSearch = false}) async* {
    if (state is WorksheetMasterSearchingState) {
      final searchState = state as WorksheetMasterSearchingState;
      final filtered = searchState.filteredItems;
      yield* scope();

      if (rebuildSearch)
        add(searchState.sourceEvent);
      else
        yield WorksheetMasterSearchingState(
          filteredItems: filtered,
          sourceEvent: (state as WorksheetMasterSearchingState).sourceEvent,
          active: _documentService.getActive(),
        );
    } else {
      yield* scope();
    }
  }

  Stream<WorksheetMasterState> _createNewWorksheet(
      WorksheetCreationMode mode) async* {
    switch (mode) {
      case WorksheetCreationMode.Import:
        yield WorksheetMasterShowImporterState(
          WorksheetImporterType.requestsImporter,
        );
        return;
      case WorksheetCreationMode.ImportCounters:
        yield WorksheetMasterShowImporterState(
          WorksheetImporterType.countersImporter,
        );
        return;
      case WorksheetCreationMode.Empty:
      default:
        yield* _safeApiCall(() async* {
          await _documentService.addNewWorksheet();
          yield WorksheetMasterIdleState(_documentService.getActive());
        });
    }
  }

  Stream<WorksheetMasterState> _handleWorksheetAction(
      RequestSetService targetRequestSet, WorksheetAction action) async* {
    switch (action) {
      case WorksheetAction.remove:
        _documentService.removeWorksheet(targetRequestSet.getRequestSet());
        break;
      case WorksheetAction.makeActive:
        _documentService.setActive(targetRequestSet.getRequestSet());
        break;
    }

    yield WorksheetMasterIdleState(_documentService.getActive());
  }

  Stream<WorksheetMasterState> _toggleSearchMode(
      WorksheetMasterSearchEvent event) async* {
    if (state is WorksheetMasterSearchingState && event.searchText == null)
      yield WorksheetMasterIdleState(_documentService.getActive());
    else {
      final filtered = _filterRequests(event.searchText);

      yield WorksheetMasterSearchingState(
        filteredItems: filtered,
        sourceEvent: event,
        active: _documentService.getActive(),
      );
    }
  }

  Map<RequestSet, List<Request>> _filterRequests(String searchText) =>
      _documentService.filterRequests(searchText);
}
