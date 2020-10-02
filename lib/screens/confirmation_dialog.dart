import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;

  const ConfirmationDialog({@required this.message}) : assert(message != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: EdgeInsets.all(8.0),
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text("Нет"),
        ),
        RaisedButton(
          onPressed: () => Navigator.pop(context, true),
          color: Theme.of(context).accentColor,
          child: Text("Да"),
        )
      ],
    );
  }
}
