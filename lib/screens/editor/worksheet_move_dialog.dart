import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:kres_requests2/models/worksheet.dart';

enum MoveMethod {
  Copy,
  Move,
}

// TODO: Don't touch Document directly. Use DocumentRepository instead
class WorksheetMoveDialog extends StatelessWidget {
  final Document document;
  final List<RequestEntity> movingRequests;
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

  String _getTitle() {
    switch (moveMethod) {
      case MoveMethod.Copy:
        return "Копирование заявок";
      case MoveMethod.Move:
        return "Перемещение заявок";
      default:
        throw ("Unknown MoveMethod $moveMethod");
    }
  }

  Iterable<Worksheet> _getTargetWorksheet() =>
      document.worksheets.where((worksheet) => worksheet != sourceWorksheet);

  void _moveRequests(Worksheet targetWorksheet) {
    targetWorksheet.requests.addAll(movingRequests);
    if (moveMethod == MoveMethod.Move)
      for (RequestEntity e in movingRequests)
        sourceWorksheet.requests.remove(e);
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
                  document.addEmptyWorksheet(name: sourceWorksheet.name);
              document.active = target;
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
