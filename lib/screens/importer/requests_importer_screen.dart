import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/bloc/importer/importer_bloc.dart';

// TODO: Replace domain layer with repository
import 'package:kres_requests2/domain/worksheet_importer.dart';

import 'package:kres_requests2/repo/config_repository.dart';
import 'package:kres_requests2/repo/requests_repository.dart';

import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/models/document.dart';

import 'base_importer_screen.dart';

class RequestsImporterScreen extends BaseImporterScreen {
  final String initialDirectory;

  factory RequestsImporterScreen.fromContext({
    @required BuildContext context,
    @required Document targetDocument,
    String initialDirectory,
  }) =>
      RequestsImporterScreen(
        targetDocument: targetDocument,
        importer: RequestsWorksheetImporter(
          requestsRepository: RequestsRepository(
            context.repository<SettingsRepository>(),
            context.repository<ConfigRepository>(),
          ),
        ),
        initialDirectory: initialDirectory,
      );

  RequestsImporterScreen({
    @required Document targetDocument,
    @required WorksheetImporter importer,
    this.initialDirectory,
  }) : super(
          title: 'Импорт заявок',
          targetDocument: targetDocument,
          mainWidgetBuilder: (_) => _RequestsImporterIdleView(),
          importer: importer,
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
          label: "Файлы Excel 97-2003",
          fileExtensions: ["xls"],
        )
      ],
    );

    return res.canceled ? null : res.paths[0];
  }
}

class _RequestsImporterIdleView extends StatelessWidget {
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
            onPressed: () => context.bloc<ImporterBloc>().add(ImportEvent()),
          )
        ],
      ),
    );
  }
}
