import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:kres_requests2/models/worksheet.dart';

enum MoveMethod {
  Copy,
  Move,
}

class WorksheetMoveDialog extends StatefulWidget {
  final Document document;
  final Set<RequestEntity> movingRequests;
  final Worksheet sourceWorksheet;
  final MoveMethod moveMethod;

  const WorksheetMoveDialog({
    @required this.document,
    @required this.movingRequests,
    @required this.sourceWorksheet,
    @required this.moveMethod,
  })  : assert(sourceWorksheet != null),
        assert(movingRequests != null),
        assert(document != null),
        assert(moveMethod != null);

  @override
  _WorksheetMoveDialogState createState() => _WorksheetMoveDialogState(
        document,
        sourceWorksheet,
        movingRequests,
        moveMethod,
      );
}

class _WorksheetMoveDialogState extends State<WorksheetMoveDialog> {
  final Set<RequestEntity> _movingRequests;
  final Worksheet _sourceWorksheet;
  final MoveMethod _moveMethod;
  final Document _document;

  _WorksheetMoveDialogState(
    this._document,
    this._sourceWorksheet,
    this._movingRequests,
    this._moveMethod,
  );

  String _getTitle() {
    switch (_moveMethod) {
      case MoveMethod.Copy:
        return "Копирование заявок";
      case MoveMethod.Move:
        return "Перемещение заявок";
      default:
        throw ("Unknown MoveMethod $_moveMethod");
    }
  }

  Iterable<Worksheet> _getTargetWorksheet() =>
      _document.worksheets.where((worksheet) => worksheet != _sourceWorksheet);

  void _moveRequests(Worksheet targetWorksheet) {
    targetWorksheet.requests.addAll(_movingRequests);
    if (_moveMethod == MoveMethod.Move)
      for (RequestEntity e in _movingRequests)
        _sourceWorksheet.requests.remove(e);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_getTitle(), textAlign: TextAlign.center),
      content: Container(
        width: 400,
        height: 300,
        child: ListView(
          children: [
            ..._getTargetWorksheet().map(
              (e) => _createListTile(FontAwesomeIcons.file, e.name, () {
                _moveRequests(e);
                Navigator.pop(context, true);
              }),
            ),
            _createListTile(FontAwesomeIcons.plus, "В новый лист", () {
              final target =
                  _document.addEmptyWorksheet(name: _sourceWorksheet.name);
              _document.active = target;
              _moveRequests(target);
              Navigator.pop(context, true);
            })
          ],
        ),
      ),
    );
  }

  Widget _createListTile(
    IconData iconData,
    String title,
    void Function() onPressed,
  ) =>
      Card(
        elevation: 3.0,
        child: ListTile(
          onTap: onPressed,
          leading: FaIcon(iconData),
          title: Text(title),
        ),
      );
}
