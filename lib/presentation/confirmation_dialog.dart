import 'package:flutter/material.dart';

/// Confirmation dialog for Yes/No choice.
/// Returns `true` on 'Yes' or `false` on 'No' choice
class ConfirmationDialog extends StatelessWidget {
  final String message;

  const ConfirmationDialog({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.all(8.0),
      content: Text(message, textAlign: TextAlign.center),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Нет'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Да'),
        )
      ],
    );
  }
}
