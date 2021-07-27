import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Dialog used to select table name from [choices] list
class TableChooserDialog extends StatelessWidget {
  final List<String> choices;

  const TableChooserDialog(this.choices, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Выберите таблицу для импорта'),
      content: SizedBox(
        width: 300.0,
        height: 440.0,
        child: ListView(
          children: choices
              .map(
                (e) => ListTile(
                  leading: const FaIcon(FontAwesomeIcons.table),
                  title: Text(e),
                  onTap: () => Navigator.pop(context, e),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
