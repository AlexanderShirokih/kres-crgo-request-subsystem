import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';
import 'package:kres_requests2/screens/editor/bloc/worksheet_editor_bloc.dart';
import 'package:kres_requests2/screens/editor/widgets/request_item_view.dart';

import 'request_editor_dialog.dart';
import 'requests_move_dialog/requests_move_dialog.dart';

// TODO: Move Marker to the left side?

/// Show the list of requests for target [worksheetEditor] of the [document]
class WorksheetEditorView extends StatefulWidget {
  /// Currently opened document
  final Document document;

  /// Target worksheet
  final WorksheetEditor worksheetEditor;

  /// A list of currently highlighted requests
  final Stream<List<RequestEntity>> highlighted;

  const WorksheetEditorView({
    Key? key,
    required this.document,
    required this.worksheetEditor,
    required this.highlighted,
  }) : super(key: key);

  @override
  _WorksheetEditorViewState createState() => _WorksheetEditorViewState();
}

class _WorksheetEditorViewState extends State<WorksheetEditorView> {
  final _controller = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WorksheetEditorBloc(worksheet: widget.worksheetEditor),
      child: BlocBuilder<WorksheetEditorBloc, WorksheetEditorState>(
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
            return _buildWorksheetList(context, state);
          }

          throw 'Unexpected state: $state';
        },
      ),
    );
  }

  Widget _showPlaceholder() => Center(
        child: Text(
          'Список пуст',
          style: Theme.of(context)
              .textTheme
              .headline3!
              .copyWith(color: Theme.of(context).textTheme.caption!.color),
        ),
      );

  // Builds the worksheet list
  Widget _buildWorksheetList(BuildContext context, WorksheetDataState state) {
    final isSelected = state is WorksheetSelectionState;

    return Stack(
      children: [
        if (state.isEmpty)
          _showPlaceholder()
        else
          Center(
            child: SizedBox(
              width: 895.0,
              child: Scrollbar(
                child: _buildContent(
                  context,
                  state,
                  isSelected,
                ),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: FloatingActionButton(
              child: FaIcon(FontAwesomeIcons.plus),
              tooltip: "Добавить заявку",
              onPressed: () {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => RequestEditorDialog(
                          controller: Modular.get(),
                          validator: Modular.get(),
                        )).then((created) {
                  if (created != null) {
                    context
                        .read<WorksheetEditorBloc>()
                        .add(SaveRequestEvent(created));
                  }
                });
              },
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
              .read<WorksheetEditorBloc>()
              .add(RequestSelectionEvent(SelectionAction.begin, request)),
          onDoubleTap: () {
            showDialog<RequestEntity?>(
              context: context,
              barrierDismissible: false,
              builder: (_) => RequestEditorDialog(
                controller: Modular.get(),
                validator: Modular.get(),
                initial: request,
              ),
            ).then((edited) {
              if (edited != null) {
                context
                    .read<WorksheetEditorBloc>()
                    .add(SaveRequestEvent(edited));
              }
            });
          },
          child: RequestItemView(
            request: request,
            position: index + 1,
            groupIndex: state.getGroup(request),
            defaultGroupIndex: state.lastGroupIndex,
            isHighlighted: state.getIsHighlighted(request),
            isSelected: isSelected,
            onChanged: (isSelected) => context.read<WorksheetEditorBloc>().add(
                  RequestSelectionEvent(
                    isSelected ? SelectionAction.add : SelectionAction.remove,
                    request,
                  ),
                ),
            groupChangeCallback: (newGroup) => context
                .read<WorksheetEditorBloc>()
                .add(ChangeGroupEvent(request, newGroup)),
          ),
        );
      },
      scrollController: _controller,
      padding:
          isInSelectionMode ? EdgeInsets.only(top: 64) : EdgeInsets.all(10.0),
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        context.read<WorksheetEditorBloc>().add(
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
            icon: Icon(Icons.highlight_off),
            tooltip: "Отменить выделение",
            onPressed: () => context
                .read<WorksheetEditorBloc>()
                .add(RequestSelectionEvent(SelectionAction.cancel)),
          ),
          const SizedBox(width: 24.0),
          Text(
            "Выбрано: ${state.selectedCount}",
            style: Theme.of(context).primaryTextTheme.headline6,
          ),
          const SizedBox(width: 24.0),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.checkSquare),
            tooltip: "Выбрать все",
            onPressed: () => context
                .read<WorksheetEditorBloc>()
                .add(RequestSelectionEvent(SelectionAction.selectAll)),
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
              onPressed: () => context.read<WorksheetEditorBloc>().add(
                  RequestSelectionEvent(SelectionAction.selectSingleGroup)),
            ),
          ],
          Expanded(
            child: IconTheme(
              data: Theme.of(context).primaryIconTheme,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.drive_file_move),
                    tooltip: "Переместить",
                    onPressed: () =>
                        _showMoveDialog(context, MoveMethod.move, state),
                  ),
                  const SizedBox(width: 24.0),
                  IconButton(
                    icon: Icon(Icons.file_copy),
                    tooltip: "Копировать",
                    onPressed: () =>
                        _showMoveDialog(context, MoveMethod.copy, state),
                  ),
                  const SizedBox(width: 46.0),
                  IconButton(
                    icon: Icon(Icons.delete_forever),
                    tooltip: "Удалить (Насовсем)",
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => ConfirmationDialog(
                          message: 'Удалить выбранные заявки?',
                        ),
                      ).then((confirmed) {
                        if (confirmed != null && confirmed) {
                          context.read<WorksheetEditorBloc>().add(
                              RequestSelectionEvent(
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
  ) =>
      showDialog(
        context: context,
        builder: (_) => RequestsMoveDialog(
          document: widget.document,
          sourceWorksheet: widget.worksheetEditor.current,
          movingRequests: state.selectionList.toList(growable: false),
          moveMethod: moveMethod,
        ),
      ).then((wasChanged) {
        if (wasChanged ?? false) {
          context
              .read<WorksheetEditorBloc>()
              .add(RequestSelectionEvent(SelectionAction.cancel));
        }
      });

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
