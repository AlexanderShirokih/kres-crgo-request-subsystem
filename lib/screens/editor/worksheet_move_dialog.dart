import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/document_service.dart';

import 'package:kres_requests2/models/request.dart';
import 'package:kres_requests2/models/request_set.dart';

class WorksheetMoveDialog extends StatefulWidget {
  final DocumentService document;
  final Set<Request> movingRequests;
  final RequestSet sourceWorksheet;

  const WorksheetMoveDialog(
      {@required this.document,
      @required this.movingRequests,
      @required this.sourceWorksheet})
      : assert(sourceWorksheet != null),
        assert(movingRequests != null),
        assert(document != null);

  @override
  _WorksheetMoveDialogState createState() => _WorksheetMoveDialogState(
        document,
        sourceWorksheet,
        movingRequests,
      );
}

class _WorksheetMoveDialogState extends State<WorksheetMoveDialog> {
  final Set<Request> _movingRequests;
  final RequestSet _sourceWorksheet;
  final DocumentService _document;

  _WorksheetMoveDialogState(
    this._document,
    this._sourceWorksheet,
    this._movingRequests,
  );

  Iterable<RequestSet> _getTargetWorksheet() => _document
      .getWorksheets()
      .where((worksheet) => worksheet != _sourceWorksheet);

  Future _moveRequests(RequestSet targetWorksheet) =>
      _document.moveRequests(targetWorksheet, _movingRequests);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Перемещение заявок", textAlign: TextAlign.center),
      content: Container(
        width: 400,
        height: 300,
        child: ListView(
          children: [
            ..._getTargetWorksheet().map(
              (e) => _createListTile(FontAwesomeIcons.file, e.name, () {
                _moveRequests(e).then((value) => Navigator.pop(context, true));
              }),
            ),
            _createListTile(FontAwesomeIcons.plus, "В новый лист", () {
              _document
                  .addNewWorksheet(_sourceWorksheet.name)
                  .then((value) => Navigator.pop(context, true));
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
