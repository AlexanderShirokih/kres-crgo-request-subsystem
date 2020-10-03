import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/common/worksheet_importer.dart';
import 'package:kres_requests2/data/document.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

import 'base_importer_screen.dart';

class RequestsImporterScreen extends BaseImporterScreen {
  factory RequestsImporterScreen.fromContext({
    @required BuildContext context,
    @required Document targetDocument,
  }) =>
      RequestsImporterScreen(
        targetDocument: targetDocument,
        importer: RequestsWorksheetImporter(
          importerExecutablePath: context
              .repository<SettingsRepository>()
              .requestsImporterExecutable,
        ),
      );

  RequestsImporterScreen({
    @required Document targetDocument,
    @required WorksheetImporter importer,
  }) : super(
          title: 'Импорт заявок',
          targetDocument: targetDocument,
          mainWidgetBuilder: (document) => _RequestsImporterIdleView(document),
          importer: importer,
        );
}

class _RequestsImporterIdleView extends StatelessWidget {
  final Document _targetDocument;

  const _RequestsImporterIdleView(this._targetDocument);

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 4.0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '1. Подготовьте отчёт со списком заявок из программы Mega-billing.\n'
            '2. Сохраните отчёт в формате .XLS (Microsoft Excel 97-2003)\n'
            '3. Нажмите Открыть отчёт и выберите сохранённый файл',
            style: Theme.of(context).textTheme.headline4,
          ),
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
      initialDirectory: './',
      confirmButtonText: 'Открыть',
      allowedFileTypes: [
        FileTypeFilterGroup(
          label: "Файлы EXCEL",
          fileExtensions: ["xls"],
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
