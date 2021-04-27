import 'package:flutter/material.dart';

/// Confirmation dialog for Yes/No choice.
/// Returns `true` on 'Yes' or `false` on 'No' choice
class ConfirmationDialog extends StatelessWidget {
  final String message;

  const ConfirmationDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: EdgeInsets.all(8.0),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Нет'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Да'),
        )
      ],
    );
  }
}
