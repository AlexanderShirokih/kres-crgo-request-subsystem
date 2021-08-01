import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:kres_requests2/presentation/bloc/editor/editor_view/worksheet_navigation_routes.dart';
import 'package:meta/meta.dart';

part 'worksheet_event.dart';

part 'worksheet_state.dart';

/// BLoC responsible for control worksheet state.
class WorksheetBloc extends Bloc<WorksheetEvent, WorksheetState> {
  /// [WorksheetService] to manage worksheet updates
  final WorksheetService _worksheetService;

  final WorksheetNavigationRoutes _worksheetNavigationRoutes;

  StreamSubscription<Worksheet>? _targetSubscription;

  WorksheetBloc(
    this._worksheetService,
    this._worksheetNavigationRoutes,
  ) : super(const WorksheetInitialState());

  @override
  Stream<WorksheetState> mapEventToState(
    WorksheetEvent event,
  ) async* {
    if (event is SetCurrentWorksheetEvent) {
      yield* _keepSelectionState(_handleWorksheetUpdate(event.worksheet));
    } else if (event is EditRequestEvent) {
      yield* _editRequest(event.request);
    } else if (event is SwapRequestsEvent) {
      yield* _swapRequests(event.from, event.to);
    } else if (event is RequestSelectionEvent) {
      yield* _handleSelectionEvent(event.target, event.action);
    } else if (event is ChangeGroupEvent) {
      yield* _keepSelectionState(
          _handleGroupUpdate(event.target, event.newGroup));
    }
  }

  Stream<WorksheetState> _swapRequests(Request from, Request to) async* {
    final currentState = state;
    if (currentState is WorksheetDataState) {
      _worksheetService.swapRequest(currentState.worksheet, from, to);
    }
  }

  Stream<WorksheetState> _editRequest(Request? request) async* {
    final currentState = state;
    if (currentState is WorksheetDataState) {
      await _worksheetNavigationRoutes.showRequestEditorDialog(
        currentState.worksheet,
        currentState.document,
        request,
      );
    }
  }

  Stream<WorksheetState> _handleWorksheetUpdate(Worksheet worksheet) async* {
    final currentState = state;
    if (currentState is WorksheetDataState) {
      // Update an existing data
      yield currentState.copyWith(
        requests: worksheet.requests,
        worksheet: worksheet,
      );
    } else {
      // First time emitting
      yield WorksheetDataState(
        document: _worksheetService.document,
        requests: worksheet.requests,
        worksheet: worksheet,
      );
    }

    await _targetSubscription?.cancel();

    // Subscribe to worksheet updates
    _targetSubscription =
        _worksheetService.listenOn(worksheet).listen((updatedWorksheet) {
      add(SetCurrentWorksheetEvent(updatedWorksheet));
    });
  }

  // TODO: Remember selection list should be updated after WorksheetMoveDialog
  // TODO: affects the selected requests
  // Old code:  if (_groupList != null) {
  //               for (final selected in _selectionList!)
  //                 _groupList!.remove(selected);
  //             }
  //             _selectionList = null;

  /// Deals some action with the selection list
  Stream<WorksheetState> _handleSelectionEvent(
    Request? target,
    SelectionAction action,
  ) async* {
    final currentState = state;
    if (currentState is! WorksheetDataState) {
      return;
    }

    if (currentState is WorksheetSelectionState) {
      final worksheet = currentState.worksheet;

      // We are already in the selection state
      WorksheetDataState handleSelectionAction() {
        switch (action) {
          case SelectionAction.add:
            return WorksheetSelectionState(
              Set.of(currentState.selectionList)..add(target!),
              currentState,
            );
          case SelectionAction.remove:
            return WorksheetSelectionState(
              Set.of(currentState.selectionList)..remove(target!),
              currentState,
            );

          case SelectionAction.selectAll:
            return WorksheetSelectionState(
              worksheet.requests.toSet(),
              currentState,
            );
          case SelectionAction.selectSingleGroup:
            return WorksheetSelectionState(
              currentState.getAllByGroup(currentState.singleGroupIndex),
              currentState,
            );
          case SelectionAction.dropSelected:
            _worksheetService.removeRequests(
                worksheet, currentState.selectionList.toList());
            return currentState.copyWith();
          case SelectionAction.cancel:
            return currentState.copyWith();
          case SelectionAction.begin:
            return WorksheetSelectionState({target!}, currentState);
        }
      }

      final newState = handleSelectionAction();
      if (newState is WorksheetSelectionState && newState.selectedCount == 0) {
        // If selection list becomes empty then disable the selection mode
        yield newState.copyWith();
      } else {
        yield newState;
      }
    } else if (action == SelectionAction.begin) {
      yield WorksheetSelectionState({target!}, currentState);
    }
  }

  /// Handles changes on the request group
  Stream<WorksheetState> _handleGroupUpdate(
    Request target,
    int newGroup,
  ) async* {
    final currentState = state;
    if (currentState is! WorksheetDataState) {
      return;
    }

    // Create new modifiable map
    final Map<Request, int> newGroupList = Map.from(currentState.groupList);

    // `0` group means `no group`, else update the group
    if (newGroup == 0) {
      newGroupList.remove(target);
    } else {
      newGroupList[target] = newGroup;
    }

    yield currentState.copyWith(
      groupList: Map.unmodifiable(newGroupList),
      lastGroupIndex: newGroup,
    );
  }

  Stream<WorksheetState> _keepSelectionState(
    Stream<WorksheetState> actions,
  ) {
    final original = state;
    if (original is WorksheetSelectionState) {
      return actions.map(
        (event) =>
            event is WorksheetDataState && event is! WorksheetSelectionState
                ? WorksheetSelectionState(original.selectionList, event)
                : event,
      );
    }
    return actions;
  }

  @override
  Future<void> close() async {
    await _targetSubscription?.cancel();
    return await super.close();
  }
}
