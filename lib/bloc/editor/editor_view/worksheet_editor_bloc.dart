import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:meta/meta.dart';

part 'worksheet_editor_event.dart';
part 'worksheet_editor_state.dart';

/// BLoC responsible for control worksheet state.
class WorksheetEditorBloc
    extends Bloc<WorksheetEditorEvent, WorksheetEditorState> {
  /// The currently editing worksheet
  final WorksheetEditor worksheet;

  StreamSubscription<Worksheet>? _worksheetSubscription;

  WorksheetEditorBloc({
    required this.worksheet,
  }) : super(const WorksheetInitialState()) {
    // _worksheetSubscription = worksheet.actualState.listen((state) {
    //   add(_UpdateWorksheetStateEvent(state));
    // });
  }

  @override
  Stream<WorksheetEditorState> mapEventToState(
    WorksheetEditorEvent event,
  ) async* {
   if (event is SwapRequestsEvent) {
      worksheet.swapRequests(event.from, event.to);
    } else if (event is RequestSelectionEvent) {
      yield* _handleSelectionEvent(event.target, event.action);
    } else if (event is ChangeGroupEvent) {
      yield* _keepSelectionState(
          _handleGroupUpdate(event.target, event.newGroup));
    }
  }

  // TODO: Remember selection list should be updated after WorksheetMoveDialog
  // TODO: affects the selected requests
  // Old code:  if (_groupList != null) {
  //               for (final selected in _selectionList!)
  //                 _groupList!.remove(selected);
  //             }
  //             _selectionList = null;

  /// Deals some action with the selection list
  Stream<WorksheetEditorState> _handleSelectionEvent(
    RequestEntity? target,
    SelectionAction action,
  ) async* {
    final currentState = state;
    if (currentState is! WorksheetDataState) {
      return;
    }

    if (currentState is WorksheetSelectionState) {
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
              worksheet.current.requests.toSet(),
              currentState,
            );
          case SelectionAction.selectSingleGroup:
            return WorksheetSelectionState(
              currentState.getAllByGroup(currentState.singleGroupIndex),
              currentState,
            );
          case SelectionAction.dropSelected:
            worksheet.removeRequests(currentState.selectionList.toList());
            return currentState.copy();
          case SelectionAction.cancel:
            return currentState.copy();
          case SelectionAction.begin:
            return WorksheetSelectionState({target!}, currentState);
        }
      }

      final newState = handleSelectionAction();
      if (newState is WorksheetSelectionState && newState.selectedCount == 0) {
        // If selection list becomes empty then disable the selection mode
        yield newState.copy();
      } else {
        yield newState;
      }
    } else if (action == SelectionAction.begin) {
      yield WorksheetSelectionState({target!}, currentState);
    }
  }

  /// Handles changes on the request group
  Stream<WorksheetEditorState> _handleGroupUpdate(
    RequestEntity target,
    int newGroup,
  ) async* {
    final currentState = state;
    if (currentState is! WorksheetDataState) {
      return;
    }

    // Create new modifiable map
    final Map<RequestEntity, int> newGroupList =
        Map.from(currentState.groupList);

    // `0` group means `no group`, else update the group
    if (newGroup == 0) {
      newGroupList.remove(target);
    } else {
      newGroupList[target] = newGroup;
    }

    yield currentState.copy(
      groupList: Map.unmodifiable(newGroupList),
      lastGroupIndex: newGroup,
    );
  }

  Stream<WorksheetEditorState> _keepSelectionState(
    Stream<WorksheetEditorState> actions,
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
    await _worksheetSubscription?.cancel();
    await super.close();
  }
}
