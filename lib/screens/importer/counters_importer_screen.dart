import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';

import 'base_importer_screen.dart';

class CountersImporterScreen extends BaseImporterScreen {
  final String initialDirectory;

  @override
  dynamic getImporterParams(BuildContext context) {
    return (List<String> tables) async => showDialog<String>(
          context: context,
          builder: (_) => _TableSelectionDialog(tables),
        );
  }

  CountersImporterScreen({
    @required Document targetDocument,
    @required CountersImporterRepository importerRepository,
    this.initialDirectory,
  }) : super(
          title: 'Импорт списка счетчиков на замену',
          targetDocument: targetDocument,
          mainWidgetBuilder: (_) => _CountersImporterIdleView(),
          importerRepository: importerRepository,
          forceFileSelection: false,
        );

  @override
  Future<String> showOpenDialog(BuildContext context) async {
    final res = await showOpenPanel(
      allowsMultipleSelection: false,
      canSelectDirectories: false,
      initialDirectory: initialDirectory,
      confirmButtonText: 'Открыть',
      allowedFileTypes: [
        FileTypeFilterGroup(
          label: "Файлы Excel 2007-365",
          fileExtensions: ["xlsx"],
        )
      ],
    );

    return res.canceled ? null : res.paths[0];
  }
}

class _CountersImporterIdleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        heightFactor: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '1. Подготовьте отчёт со списком счётчиков в формате XLSX (Excel 2007-365).\n'
              '2. Расположение данных в колонках должно соответствовать примеру\n'
              '3. Нажмите Открыть отчёт и выберите сохранённый файл',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 42.0),
            Image.asset('assets/images/counters_import_template.png'),
            const SizedBox(height: 42.0),
            RaisedButton.icon(
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryTextTheme.bodyText2.color,
              padding: EdgeInsets.all(22.0),
              icon: FaIcon(FontAwesomeIcons.fileExcel),
              label: Text(
                'Открыть отчёт',
              ),
              onPressed: () => context.bloc<ImporterBloc>().add(ImportEvent()),
            )
          ],
        ),
      );
}

class _TableSelectionDialog extends StatelessWidget {
  final List<String> choices;

  const _TableSelectionDialog(this.choices) : assert(choices != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Выберите таблицу для импорта'),
      content: SizedBox(
        width: 300.0,
        height: 440.0,
        child: ListView(
          children: choices
              .map(
                (e) => ListTile(
                  leading: FaIcon(FontAwesomeIcons.table),
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
