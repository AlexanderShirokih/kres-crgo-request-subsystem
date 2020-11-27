import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/document_service.dart';

import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:kres_requests2/screens/importer/base_importer_screen.dart';

class RequestsImporterScreen extends BaseImporterScreen {
  factory RequestsImporterScreen.fromContext({
    @required RepositoryModule repositoryModule,
    @required BuildContext context,
    @required DocumentService targetDocument,
    String initialDirectory,
  }) =>
      RequestsImporterScreen(
        targetDocument: targetDocument,
        requestsRepository: repositoryModule.getRequestsRepository(),
      );

  RequestsImporterScreen({
    @required DocumentService targetDocument,
    @required RequestsRepository requestsRepository,
  }) : super(
          title: 'Импорт заявок',
          targetDocument: targetDocument,
          mainWidgetBuilder: (_) => _RequestsImporterIdleView(),
          importerRepository: requestsRepository,
          forceFileSelection: false,
        );

  @override
  Future<String> showOpenDialog(BuildContext context) async {
    final res = await showOpenPanel(
      allowsMultipleSelection: false,
      canSelectDirectories: false,
      initialDirectory: './',
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

  @override
  dynamic getImporterParams(BuildContext context) => null;
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
            label: Text('Открыть отчёт'),
            onPressed: () => context.read<ImporterBloc>().add(ImportEvent()),
          )
        ],
      ),
    );
  }
}
