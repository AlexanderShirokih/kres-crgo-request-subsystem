import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/repo/document_repository.dart';
import 'package:kres_requests2/repo/models/request_wrapper.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';
import 'package:kres_requests2/screens/editor/reorderable_list_view.dart';
import 'package:kres_requests2/screens/editor/request_item_view.dart';

import '../common.dart';
import 'request_editor_dialog.dart';
import 'worksheet_move_dialog.dart';

class WorkSheetEditorView extends StatefulWidget {
  final DocumentRepository documentRepository;

  const WorkSheetEditorView({
    @required this.documentRepository,
  }) : assert(documentRepository != null);

  @override
  _WorkSheetEditorViewState createState() => _WorkSheetEditorViewState();
}

class _WorkSheetEditorViewState extends State<WorkSheetEditorView> {
  final _controller = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.documentRepository;
    return StreamBuilder<List<RequestWrapper>>(
        stream: repo.activeRequests,
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return ErrorView(errorDescription: snapshot.error.toString());
          else if (snapshot.data == null)
            return Center(child: Text('Нет данных. Возможно что-то сломалось'));
          else
            return Stack(
              children: [
                snapshot.data.isEmpty
                    ? _showPlaceholder()
                    : ConstrainedBox(
                        constraints: BoxConstraints(minWidth: 600.0),
                        child: _buildListContent(snapshot.data),
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
                                builder: (_) => RequestEditorDialog())
                            .then((created) {
                          if (created != null) {
                            repo.addRequestToActive(created);
                          }
                        });
                      },
                    ),
                  ),
                ),
                if (snapshot.data.where((e) => e.isSelected).isNotEmpty)
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
                      width: double.maxFinite,
                      height: 64.0,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: _createSelectionContextMenu(),
                    ),
                  ),
              ],
            );
        });
  }

  Widget _buildListContent(List<RequestWrapper> data) {
    final repo = widget.documentRepository;
    final isSelectionEnabled = data.where((e) => e.isSelected).isNotEmpty;

    return MyReorderableListView(
      scrollController: _controller,
      padding:
          isSelectionEnabled ? EdgeInsets.only(top: 64) : EdgeInsets.all(10.0),
      onReorder: (int oldIndex, int newIndex) {
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        final toRemove = data[oldIndex];
        final toInsertAfter = data[newIndex];
        repo.replaceActive(toRemove, toInsertAfter);
      },
      children: List.generate(
        data.length,
        (index) {
          final requestItem = data[index];
          return GestureDetector(
            key: Key(
                requestItem.toString() + Random().nextInt(100000).toString()),
            onLongPress: () {
              repo.clearSelection(updateState: false);
              repo.setSelected(requestItem, true);
            },
            onDoubleTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => RequestEditorDialog(
                  editingRequest: requestItem.request,
                ),
              ).then((edited) {
                if (edited != null) {
                  repo.setActiveRequest(requestItem, edited);
                }
              });
            },
            child: RequestItemView(
              defaultGroupIndex: repo.lastGroupIndex,
              position: index + 1,
              request: requestItem.request,
              groupIndex: requestItem.groupIndex,
              isHighlighted: requestItem.isHighlighted,
              isSelected: isSelectionEnabled ? requestItem.isSelected : null,
              key: ValueKey(requestItem.request),
              onChanged: (isSelected) =>
                  repo.setSelected(requestItem, isSelected),
              groupChangeCallback: (newGroup) =>
                  repo.setGroup(requestItem, newGroup),
            ),
          );
        },
      ),
    );
  }

  Widget _showPlaceholder() => Center(
        child: Text(
          'Список пуст',
          style: Theme.of(context)
              .textTheme
              .headline3
              .copyWith(color: Theme.of(context).textTheme.caption.color),
        ),
      );

  Widget _createSelectionContextMenu() {
    final repo = widget.documentRepository;
    final singleSelectedGroup = repo.activeSingleSelectedGroup;
    return Row(
      children: [
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          tooltip: "Отменить выделение",
          onPressed: () => repo.clearSelection(),
        ),
        const SizedBox(width: 24.0),
        Text(
          "Выбрано: ${repo.activeSelected.length}",
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        const SizedBox(width: 24.0),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.checkSquare,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          tooltip: "Выбрать все",
          onPressed: () => repo.selectAllActive(),
        ),
        if (singleSelectedGroup != null) ...[
          const SizedBox(width: 24.0),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.highlighter,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            tooltip:
                "Выбрать все этой группы (${_translateGroupName(singleSelectedGroup)})",
            onPressed: () => repo.selectAllActive(group: singleSelectedGroup),
          ),
        ],
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _selectionActionButton(
                iconData: FontAwesomeIcons.folderOpen,
                tooltip: "Переместить",
                onPressed: () => _showWorksheetMoveDialog(MoveMethod.Move),
              ),
              const SizedBox(width: 24.0),
              _selectionActionButton(
                iconData: FontAwesomeIcons.copy,
                tooltip: "Копировать",
                onPressed: () => _showWorksheetMoveDialog(MoveMethod.Copy),
              ),
              const SizedBox(width: 46.0),
              _selectionActionButton(
                iconData: FontAwesomeIcons.times,
                tooltip: "Удалить (Насовсем)",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmationDialog(
                      message: 'Удалить выбранные заявки?',
                    ),
                  ).then((confirmed) {
                    if (confirmed != null && confirmed) {
                      repo.removeActiveRequests(repo.activeSelected);
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showWorksheetMoveDialog(MoveMethod moveMethod) {
    final repo = widget.documentRepository;
    final selected = repo.activeSelected;

    showDialog(
      context: context,
      builder: (_) => WorksheetMoveDialog(
        document: repo.document,
        sourceWorksheet: repo.document.active,
        movingRequests: selected,
        moveMethod: moveMethod,
      ),
    ).then((hasChanges) {
      if (hasChanges != null) {
        repo.clearDecoration(selected);
      }
    });
  }

  Widget _selectionActionButton({
    IconData iconData,
    String tooltip,
    void Function() onPressed,
  }) =>
      IconButton(
        icon: FaIcon(
          iconData,
          color: Theme.of(context).primaryIconTheme.color,
        ),
        tooltip: tooltip,
        onPressed: onPressed,
      );

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
