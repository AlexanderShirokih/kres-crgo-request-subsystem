import 'package:flutter/material.dart';

/// Shows [AlertDialog] that asks for saving changes.
/// [showDialog] will return `false` is user confirms saving,
/// `true` is user wants to discard changes, and `null` if dialog was cancelled.
class SaveChangesDialog extends StatelessWidget {
  const SaveChangesDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Подтвердите действие'),
      content: const Text('Сохранить внесенные изменения?'),
      actionsPadding: const EdgeInsets.all(12.0),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Отмена'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Не сохранять'),
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
