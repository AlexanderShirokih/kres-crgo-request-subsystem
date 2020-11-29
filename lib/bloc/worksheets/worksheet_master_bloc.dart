import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:kres_requests2/domain/document_service.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/models/request.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

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
    if (event is WorksheetMasterSearchEvent) {
      yield* _toggleSearchMode(event);
    } else if (event is WorksheetMasterRefreshDocumentStateEvent) {
      yield* _keepSearchingState(
          () => Stream.value(
              WorksheetMasterIdleState(_documentService.getActive())),
          rebuildSearch: true);
    } else if (event is WorksheetShowNotificationEvent) {
      yield* _keepSearchingState(() async* {
        final current = state;
        yield WorksheetNotificationState(event.message);
        yield current;
      });
    }
  }

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
