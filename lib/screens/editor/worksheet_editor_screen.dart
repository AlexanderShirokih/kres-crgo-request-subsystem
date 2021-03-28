import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';
import 'package:kres_requests2/screens/editor/widgets/request_item_view.dart';

import 'request_editor_dialog.dart';
import 'worksheet_move_dialog.dart';

/// Show the list of requests for target [worksheet] of the [document]
class WorksheetEditorView extends StatefulWidget {
  /// Currently opened document
  final Document document;

  /// Target worksheet
  final Worksheet worksheet;

  /// A list of currently highlighted worksheets
  final Stream<List<RequestEntity>> highlighted;

  const WorksheetEditorView({
    required this.document,
    required this.worksheet,
    required this.highlighted,
  });

  @override
  _WorksheetEditorViewState createState() => _WorksheetEditorViewState();
}

class _WorksheetEditorViewState extends State<WorksheetEditorView> {
  final _controller = ScrollController();

  Set<RequestEntity>? _selectionList;
  Map<RequestEntity, int>? _groupList;

  int _lastGroupIndex = 0;

  bool get _isSelected => _selectionList != null;

  int get _selectedCount => _selectionList!.fold(0, (prev, val) => prev + 1);

  int? get _singleGroup {
    if (_groupList == null || !_isSelected) return null;

    final filtered = _selectionList!
        .map((e) => _groupList![e])
        .where((e) => e != null)
        .toSet();

    return filtered.length == 1 ? filtered.single : null;
  }

  Set<RequestEntity> getAllByGroup(int group) {
    if (_groupList == null || !_isSelected) return {};

    return _groupList!.entries
        .where((e) => e.value == group)
        .map((e) => e.key)
        .toSet();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  List<RequestEntity> _buildRequestsList() {
    return widget.worksheet.requests ?? [];
    // TODO: BROKEN
    // final output = [...widget.highlighted!];
    // for (final request in _worksheet.requests!) {
    //   if (!output.contains(request)) output.add(request);
    // }
    // return output;
  }

  @override
  Widget build(BuildContext context) {
    final worksheet = widget.worksheet;
    if (worksheet.isEmpty) _selectionList = null;

    final requests = _buildRequestsList();

    return Stack(
      children: [
        worksheet.isEmpty
            ? _showPlaceholder()
            : Center(
              child: SizedBox(
                width: 840.0,
                  child: ReorderableListView(
                    scrollController: _controller,
                    padding: _isSelected
                        ? EdgeInsets.only(top: 64)
                        : EdgeInsets.all(10.0),
                    onReorder: (int oldIndex, int newIndex) => setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }

                      // We shouldn't modify [requests] list directly because it's
                      // just a copy of [_worksheet.requests]

                      // Transform shadow list indices to original indices
                      final toRemove = requests[oldIndex];
                      final toInsertAfter = requests[newIndex];

                      final idx = worksheet.requests!.indexOf(toInsertAfter);
                      worksheet.requests!.remove(toRemove);
                      worksheet.requests!.insert(idx, toRemove);
                    }),
                    children: List.generate(
                      requests.length,
                      (index) => GestureDetector(
                        key: Key(requests[index].toString() +
                            Random().nextInt(100000).toString()),
                        onLongPress: () => setState(() {
                          _selectionList = {requests[index]};
                        }),
                        onDoubleTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => RequestEditorDialog(
                              controller: Modular.get(),
                              validator: Modular.get(),
                              initial: requests[index],
                            ),
                          ).then((edited) {
                            if (edited != null)
                              setState(() {
                                // TODO: REMOTE DEAD CODE
                                // If previous value was selected then update
                                // selection references
                                final old = requests[index];
                                if (_selectionList != null &&
                                    _selectionList!.contains(old)) {
                                  _selectionList!
                                    ..remove(old)
                                    ..add(edited);
                                }
                                final oldIdx = worksheet.requests!.indexOf(old);
                                worksheet.requests![oldIdx] = edited;
                              });
                            // widget.onDocumentsChanged();
                          });
                        },
                        child: RequestItemView(
                          defaultGroupIndex: _lastGroupIndex,
                          position: index + 1,
                          groupIndex: _groupList != null
                              ? _groupList![requests[index]] ?? 0
                              : 0,
                          isSelected: _isSelected
                              ? _selectionList!.contains(requests[index])
                              : null,
                          isHighlighted: false,
                          // widget.highlighted != null &&
                          //     widget.highlighted!.contains(requests[index]),
                          request: requests[index],
                          key: ObjectKey(requests[index].accountId),
                          onChanged: (isSelected) => setState(() {
                            final value = requests[index];
                            if (isSelected!) {
                              _selectionList!.add(value);
                            } else {
                              _selectionList!.remove(value);
                            }
                            if (_selectionList!.isEmpty) _selectionList = null;
                          }),
                          groupChangeCallback: (newGroup) => setState(() {
                            _lastGroupIndex = newGroup;
                            if (_groupList == null) {
                              _groupList = {requests[index]: newGroup};
                            } else if (newGroup == 0) {
                              _groupList!.remove(requests[index]);
                            } else {
                              _groupList![requests[index]] = newGroup;
                            }
                          }),
                        ),
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
                    builder: (_) => RequestEditorDialog(
                          controller: Modular.get(),
                          validator: Modular.get(),
                        )).then((created) {
                  if (created != null) {
                    setState(() {
                      requests.add(created);
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
              .headline3!
              .copyWith(color: Theme.of(context).textTheme.caption!.color),
        ),
      );

  Widget _createSelectionContextMenu() {
    final singleGroup = _singleGroup;
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
          tooltip: "Выбрать все",
          onPressed: () => setState(() {
            _selectionList = widget.worksheet.requests!.toSet();
          }),
        ),
        if (singleGroup != null) ...[
          const SizedBox(width: 24.0),
          IconButton(
            icon: FaIcon(
              FontAwesomeIcons.highlighter,
              color: Theme.of(context).primaryIconTheme.color,
            ),
            tooltip:
                "Выбрать все этой группы (${_translateGroupName(singleGroup)})",
            onPressed: () => setState(() {
              _selectionList = getAllByGroup(singleGroup);
            }),
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
                      setState(() {
                        for (final selected in _selectionList!)
                          widget.worksheet.requests!.remove(selected);
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
          document: widget.document,
          sourceWorksheet: widget.worksheet,
          movingRequests: _selectionList!,
          moveMethod: moveMethod,
        ),
      ).then((hasChanges) {
        if (hasChanges != null) {
          setState(() {
            if (_groupList != null) {
              for (final selected in _selectionList!)
                _groupList!.remove(selected);
            }
            _selectionList = null;
          });
          // widget.onDocumentsChanged();
        }
      });

  Widget _selectionActionButton({
    required IconData iconData,
    required String tooltip,
    required void Function() onPressed,
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
