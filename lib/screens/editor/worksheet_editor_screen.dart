import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/document.dart';
import 'package:kres_requests2/data/request_entity.dart';
import 'package:kres_requests2/data/worksheet.dart';
import 'package:kres_requests2/screens/editor/reorderable_list_view.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';

import 'request_editor_dialog.dart';
import 'worksheet_move_dialog.dart';

class WorkSheetEditorView extends StatefulWidget {
  final Document document;
  final Worksheet worksheet;
  final void Function() onDocumentsChanged;

  const WorkSheetEditorView({
    @required this.document,
    @required this.worksheet,
    @required this.onDocumentsChanged,
  })  : assert(document != null),
        assert(worksheet != null),
        assert(onDocumentsChanged != null);

  @override
  _WorkSheetEditorViewState createState() =>
      _WorkSheetEditorViewState(document, worksheet);
}

class _WorkSheetEditorViewState extends State<WorkSheetEditorView> {
  final _controller = ScrollController();
  Document _document;
  Worksheet _worksheet;

  _WorkSheetEditorViewState(this._document, this._worksheet);

  Set<RequestEntity> _selectionList;

  bool get _isSelected => _selectionList != null;

  int get _selectedCount => _selectionList.fold(0, (prev, val) => prev + 1);

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _worksheet = widget.worksheet;
    if (_worksheet.isEmpty) _selectionList = null;

    return Stack(
      children: [
        _worksheet.isEmpty
            ? _showPlaceholder()
            : ConstrainedBox(
                constraints: BoxConstraints(minWidth: 600.0),
                child: MyReorderableListView(
                  scrollController: _controller,
                  padding: _isSelected
                      ? EdgeInsets.only(top: 64)
                      : EdgeInsets.all(10.0),
                  onReorder: (int oldIndex, int newIndex) => setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _worksheet.requests.removeAt(oldIndex);
                    _worksheet.requests.insert(newIndex, item);
                  }),
                  children: List.generate(
                    _worksheet.requests.length,
                    (index) => GestureDetector(
                      key: Key(_worksheet.requests[index].toString() +
                          Random().nextInt(100000).toString()),
                      onLongPress: () => setState(() {
                        _selectionList = {_worksheet.requests[index]};
                      }),
                      onDoubleTap: () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => RequestEditorDialog(
                            editingRequest: _worksheet.requests[index],
                          ),
                        ).then((edited) {
                          if (edited != null)
                            setState(() {
                              _worksheet.requests[index] = edited;
                            });
                        });
                      },
                      child: _RequestItemView(
                        position: index + 1,
                        isSelected: _isSelected
                            ? _selectionList
                                .contains(_worksheet.requests[index])
                            : null,
                        request: _worksheet.requests[index],
                        key: ValueKey(_worksheet.requests[index].accountId),
                        onChanged: (isSelected) => setState(() {
                          final value = _worksheet.requests[index];
                          if (isSelected) {
                            _selectionList.add(value);
                          } else {
                            _selectionList.remove(value);
                          }
                          if (_selectionList.isEmpty) _selectionList = null;
                        }),
                      ),
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
                    builder: (_) => RequestEditorDialog()).then((created) {
                  if (created != null) {
                    setState(() {
                      _worksheet.requests.add(created);
                    });
                  }
                });
              },
            ),
          ),
        ),
        if (_isSelected)
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
    return Row(
      children: [
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          tooltip: "Отменить выделение",
          onPressed: () => setState(() {
            _selectionList = null;
          }),
        ),
        const SizedBox(width: 24.0),
        Text(
          "Выбрано: $_selectedCount",
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
        const SizedBox(width: 24.0),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.checkSquare,
            color: Theme.of(context).primaryIconTheme.color,
          ),
          tooltip: "Выбрать всё",
          onPressed: () => setState(() {
            _selectionList = _worksheet.requests.toSet();
          }),
        ),
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
                      setState(() {
                        for (final selected in _selectionList)
                          _worksheet.requests.remove(selected);
                        _selectionList = null;
                      });
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

  void _showWorksheetMoveDialog(MoveMethod moveMethod) => showDialog(
        context: context,
        builder: (_) => WorksheetMoveDialog(
          document: _document,
          sourceWorksheet: _worksheet,
          movingRequests: _selectionList,
          moveMethod: moveMethod,
        ),
      ).then((hasChanges) {
        if (hasChanges != null) {
          setState(() {
            _selectionList = null;
          });
          widget.onDocumentsChanged();
        }
      });

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
}

class _RequestItemView extends StatelessWidget {
  final int position;
  final RequestEntity request;

  // true - selected, false - not selected, null - not in selection mode
  final bool isSelected;

  final void Function(bool) onChanged;

  const _RequestItemView({
    @required this.position,
    @required this.isSelected,
    @required this.request,
    @required this.onChanged,
    Key key,
  })  : assert(onChanged != null),
        assert(position != null),
        assert(request != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isSelected != null) onChanged(!isSelected);
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 90.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isSelected != null)
                  Checkbox(value: isSelected, onChanged: onChanged),
                SizedBox(
                  width: 18.0,
                  child: Text(position.toString()),
                ),
                const SizedBox(width: 8.0),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.accountId?.toString()?.padLeft(6, '0') ?? "--",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(request.reqType ?? "--"),
                  ],
                ),
                const SizedBox(width: 12.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 380.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.name,
                        style: TextStyle(
                          fontSize: 22.0,
                        ),
                      ),
                      const SizedBox(height: 6.0),
                      Text(
                        request.address,
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24.0),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 380.0,
                    maxWidth: 420.0,
                  ),
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.counterInfo,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          request.additionalInfo,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
