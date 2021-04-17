import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/importer/base_importer_screen.dart';

/// The page responsible for opening native file formats
class NativeImporterScreen extends BaseImporterScreen {
  final NativeImporterRepository importerRepository;
  final String? initialDirectory;
  final Document? targetDocument;

  NativeImporterScreen({
    required this.importerRepository,
    this.targetDocument,
    this.initialDirectory,
    File? openPath,
  }) : super(
          title: 'Импорт файла',
          importerRepository: importerRepository,
          targetDocument: targetDocument,
          mainWidgetBuilder: (_) => LoadingView('Ожидание открытия файла...'),
          openPath: openPath,
        );

  @override
  Future<String?> showOpenDialog(BuildContext context) async {
    final res = await openFile(
      initialDirectory: initialDirectory,
      confirmButtonText: 'Открыть',
      acceptedTypeGroups: [
        XTypeGroup(
          label: "Документ заявок",
          extensions: ["json"],
        )
      ],
    );

    return res?.path;
  }
}

class SelectWorksheetsDialog extends StatefulWidget {
  final List<Worksheet> tables;

  const SelectWorksheetsDialog(this.tables);

  @override
  _SelectWorksheetsDialogState createState() =>
      _SelectWorksheetsDialogState(tables.length);
}

class _SelectWorksheetsDialogState extends State<SelectWorksheetsDialog> {
  List<bool> _selected;

  _SelectWorksheetsDialogState(int length)
      : _selected = List.filled(length, true, growable: false);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Выберите листы для импорта'),
      content: SizedBox(
        width: 300.0,
        height: 300.0,
        child: ListView(
          children: Iterable.generate(
            widget.tables.length,
            (i) => CheckboxListTile(
              value: _selected[i],
              title: Text(widget.tables[i].name),
              subtitle: Text('Заявок: ${widget.tables[i].requests.length}'),
              onChanged: (val) => setState(() {
                _selected[i] = val!;
              }),
            ),
          ).toList(),
        ),
      ),
      actionsPadding: EdgeInsets.only(right: 18.0, bottom: 8.0),
      actions: [
        ElevatedButton(
          child: Text('Выбрать'),
          onPressed: () => Navigator.pop(
            context,
            _selected.where((s) => s).isEmpty
                ? null
                : Iterable.generate(
                        widget.tables.length,
                        (i) => MapEntry<bool, Worksheet>(
                            _selected[i], widget.tables[i]))
                    .where((element) => element.key)
                    .map((e) => e.value)
                    .toList(),
          ),
        ),
      ],
    );
  }
}
