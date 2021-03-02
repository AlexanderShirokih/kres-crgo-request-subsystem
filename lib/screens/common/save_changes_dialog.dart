import 'package:flutter/material.dart';

/// Shows [AlertDialog] that asks for saving changes.
/// [showDialog] will return `false` is user confirms saving,
/// `true` is user wants to discard changes, and `null` if dialog was cancelled.
class SaveChangesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Подтвердите действие'),
      content: Text('Сохранить внесенные изменения?'),
      actionsPadding: EdgeInsets.all(12.0),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Отмена'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Не сохранять'),
          ),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}
