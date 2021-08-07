import 'package:flutter/material.dart';

class ImportWarningDialog extends StatelessWidget {
  const ImportWarningDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.all(12.0),
      title: const Text('Импорт данных'),
      content: const Text('Будет выполен импорт данных из SQL сценария. \n'
          'Это действие может привести к потере всех данных. \n'
          'Вы уверены что хотите выполнить импорт?'),
      actions: [
        ElevatedButton(
          child: const Text('Отмена'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        const SizedBox(width: 16.0),
        TextButton(
          child: const Text('Выполнить импорт'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
