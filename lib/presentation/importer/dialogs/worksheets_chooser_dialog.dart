import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kres_requests2/domain/models.dart';

/// Dialog used to choose worksheets to import
class WorksheetsChooserDialog extends HookWidget {
  final List<Worksheet> tables;

  const WorksheetsChooserDialog(this.tables);

  @override
  Widget build(BuildContext context) {
    final selected = useState(Set<Worksheet>.from(tables));

    return AlertDialog(
      title: Text('Выберите листы для импорта'),
      content: SizedBox(
        width: 300.0,
        height: 300.0,
        child: ListView(
          children: tables
              .map((ws) => CheckboxListTile(
                    value: selected.value.contains(ws),
                    title: Text(ws.name),
                    subtitle: Text('Заявок: ${ws.requests.length}'),
                    onChanged: (newValue) {
                      selected.value = newValue == true
                          ? Set.of(selected.value..add(ws))
                          : Set.of(selected.value..remove(ws));
                    },
                  ))
              .toList(),
        ),
      ),
      actionsPadding: EdgeInsets.only(right: 18.0, bottom: 8.0),
      actions: [
        ElevatedButton(
          child: Text('Выбрать'),
          onPressed: () => Navigator.pop(context, selected.value.toList()),
        ),
      ],
    );
  }
}
