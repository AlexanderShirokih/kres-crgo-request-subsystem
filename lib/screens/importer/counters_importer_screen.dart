import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/common/worksheet_importer.dart';
import 'package:kres_requests2/data/document.dart';

import 'base_importer_screen.dart';

class CountersImporterScreen extends BaseImporterScreen {
  final String initialDirectory;

  CountersImporterScreen({
    @required Document targetDocument,
    @required WorksheetImporter importer,
    this.initialDirectory,
  }) : super(
          title: 'Импорт списка счетчиков на замену',
          targetDocument: targetDocument,
          mainWidgetBuilder: (document) => _CountersImporterIdleView(
            document,
            initialDirectory,
          ),
          importer: importer,
        );
}

class _CountersImporterIdleView extends StatelessWidget {
  final Document _targetDocument;
  final String _initialDirectory;

  const _CountersImporterIdleView(
    this._targetDocument,
    this._initialDirectory,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
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
            onPressed: () => _showImportDialog(context),
          )
        ],
      ),
    );
  }

  Future _showImportDialog(BuildContext context) async {
    final res = await showOpenPanel(
      allowsMultipleSelection: false,
      canSelectDirectories: false,
      initialDirectory: _initialDirectory,
      confirmButtonText: 'Открыть',
      allowedFileTypes: [
        FileTypeFilterGroup(
          label: "Файлы Excel 2007-365",
          fileExtensions: ["xlsx"],
        )
      ],
    );
    if (res.canceled) return;

    context.bloc<ImporterBloc>().add(
          ImportEvent(
            path: res.paths[0],
            targetDocument: _targetDocument,
          ),
        );
  }
}
