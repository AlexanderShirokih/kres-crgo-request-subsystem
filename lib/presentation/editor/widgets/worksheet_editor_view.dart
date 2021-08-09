import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/presentation/bloc/editor/editor_view/worksheet_bloc.dart';
import 'package:kres_requests2/presentation/editor/requests_move_dialog/requests_move_dialog.dart';
import 'package:kres_requests2/presentation/editor/widgets/request_item_view.dart';

import '../../confirmation_dialog.dart';

/// Show the list of requests for target worksheet.
/// Requires [WorksheetBloc] to be injected.
class WorksheetEditorView extends HookWidget {
  /// A list of currently highlighted requests
  /// TODO: FIX
  // final Stream<List<RequestEntity>> highlighted;

  WorksheetEditorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scroll = useScrollController();
    return BlocBuilder<WorksheetBloc, WorksheetState>(
      builder: (context, state) {
        if (state is WorksheetInitialState) {
          return Center(
            child: Text(
              'Загрузка...',
              style: Theme.of(context).textTheme.headline6,
            ),
          );
        }

        if (state is WorksheetDataState) {
          return _buildWorksheetList(context, state, scroll);
        }

        throw 'Unexpected state: $state';
      },
    );
  }

  Widget _showPlaceholder(BuildContext context) => Center(
        child: Text(
          'Список пуст',
          style: Theme.of(context)
              .textTheme
              .headline3!
              .copyWith(color: Theme.of(context).textTheme.caption!.color),
        ),
      );

  // Builds the worksheet list
  Widget _buildWorksheetList(
    BuildContext context,
    WorksheetDataState state,
    ScrollController scroll,
  ) {
    final isSelected = state is WorksheetSelectionState;

    return Stack(
      children: [
        if (state.isEmpty)
          _showPlaceholder(context)
        else
          Center(
            child: SizedBox(
              width: 895.0,
              child: _buildContent(context, state, scroll, isSelected),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: FloatingActionButton(
              heroTag: null,
              child: const FaIcon(FontAwesomeIcons.plus),
              tooltip: "Добавить заявку",
              onPressed: () =>
                  context.read<WorksheetBloc>().add(const EditRequestEvent()),
            ),
          ),
        ),
        if (isSelected)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.rectangle,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0.0, 4.0),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                  )
                ],
              ),
              height: 64.0,
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _createSelectionContextMenu(
                state: state as WorksheetSelectionState,
                context: context,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    WorksheetDataState state,
    ScrollController controller,
    bool isInSelectionMode,
  ) {
    final requests = state.requests;
    return ReorderableListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        bool? isSelected;
        if (state is WorksheetSelectionState) {
          isSelected = state.getIsSelected(request);
        }

        return GestureDetector(
          key: ObjectKey(request),
          onLongPress: () => context
              .read<WorksheetBloc>()
              .add(RequestSelectionEvent(SelectionAction.begin, request)),
          onDoubleTap: () =>
              context.read<WorksheetBloc>().add(EditRequestEvent(request)),
          child: RequestItemView(
            request: request,
            position: index + 1,
            groupIndex: state.getGroup(request),
            defaultGroupIndex: state.lastGroupIndex,
            isHighlighted: state.getIsHighlighted(request),
            isSelected: isSelected,
            onChanged: (isSelected) => context.read<WorksheetBloc>().add(
                  RequestSelectionEvent(
                    isSelected ? SelectionAction.add : SelectionAction.remove,
                    request,
                  ),
                ),
            groupChangeCallback: (newGroup) => context
                .read<WorksheetBloc>()
                .add(ChangeGroupEvent(request, newGroup)),
          ),
        );
      },
      scrollController: controller,
      padding: isInSelectionMode
          ? const EdgeInsets.only(top: 64)
          : const EdgeInsets.all(10.0),
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        context.read<WorksheetBloc>().add(
              SwapRequestsEvent(
                from: requests[oldIndex],
                to: requests[newIndex],
              ),
            );
      },
    );
  }

  Widget _createSelectionContextMenu({
    required BuildContext context,
    required WorksheetSelectionState state,
  }) {
    final singleGroup = state.singleGroupIndex;
    return IconTheme(
      data: Theme.of(context).primaryIconTheme,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.highlight_off),
            tooltip: "Отменить выделение",
            onPressed: () => context
                .read<WorksheetBloc>()
                .add(const RequestSelectionEvent(SelectionAction.cancel)),
          ),
          const SizedBox(width: 24.0),
          Text(
            "Выбрано: ${state.selectedCount}",
            style: Theme.of(context).primaryTextTheme.headline6,
          ),
          const SizedBox(width: 24.0),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.checkSquare),
            tooltip: "Выбрать все",
            onPressed: () => context
                .read<WorksheetBloc>()
                .add(const RequestSelectionEvent(SelectionAction.selectAll)),
          ),
          if (singleGroup != 0) ...[
            const SizedBox(width: 24.0),
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.highlighter,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              tooltip:
                  "Выбрать все этой группы (${_translateGroupName(singleGroup)})",
              onPressed: () => context.read<WorksheetBloc>().add(
                  const RequestSelectionEvent(
                      SelectionAction.selectSingleGroup)),
            ),
          ],
          Expanded(
            child: IconTheme(
              data: Theme.of(context).primaryIconTheme,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.drive_file_move),
                    tooltip: "Переместить",
                    onPressed: () =>
                        _showMoveDialog(context, MoveMethod.move, state),
                  ),
                  const SizedBox(width: 24.0),
                  IconButton(
                    icon: const Icon(Icons.file_copy),
                    tooltip: "Копировать",
                    onPressed: () =>
                        _showMoveDialog(context, MoveMethod.copy, state),
                  ),
                  const SizedBox(width: 46.0),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    tooltip: "Удалить (Насовсем)",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const ConfirmationDialog(
                          message: 'Удалить выбранные заявки?',
                        ),
                      ).then((confirmed) {
                        if (confirmed != null && confirmed) {
                          context.read<WorksheetBloc>().add(
                              const RequestSelectionEvent(
                                  SelectionAction.dropSelected));
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog(
    BuildContext context,
    MoveMethod moveMethod,
    WorksheetSelectionState state,
  ) {
    showDialog(
      context: context,
      builder: (_) => RequestsMoveDialog(
        sourceDocument: state.document,
        sourceWorksheet: state.worksheet,
        movingRequests: state.selectionList.toList(growable: false),
        moveMethod: moveMethod,
      ),
    ).then((wasChanged) {
      if (wasChanged ?? false) {
        context
            .read<WorksheetBloc>()
            .add(const RequestSelectionEvent(SelectionAction.cancel));
      }
    });
  }

  final _groupNames = [
    'белый',
    'зелёный',
    'красный',
    'фиолет.',
    'оранж.',
    'синий',
    'бирюз.'
  ];

  String _translateGroupName(int group) => _groupNames[group];
}
