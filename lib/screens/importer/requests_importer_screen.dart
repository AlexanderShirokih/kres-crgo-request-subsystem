import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/repo/requests_service.dart';
import 'package:kres_requests2/screens/importer/base_importer_screen.dart';

/// Request import wizard
class RequestsImporterScreen extends BaseImporterScreen {
  // TODO: Load initial directory from preferences (lastWorkspaceDirectory)
  final String? initialDirectory;

  RequestsImporterScreen({
    required Document targetDocument,
    required RequestsService requestsRepository,
    this.initialDirectory,
  }) : super(
          title: 'Импорт заявок',
          targetDocument: targetDocument,
          mainWidgetBuilder: (_) => _RequestsImporterIdleView(),
          importerRepository: requestsRepository,
        );

  @override
  Future<String?> showOpenDialog(BuildContext context) async {
    return await openFile(
      initialDirectory: initialDirectory,
      confirmButtonText: 'Открыть',
      acceptedTypeGroups: [
        XTypeGroup(
          label: "Файлы Excel 97-2003",
          extensions: ["xls"],
        )
      ],
    ).then((file) => file?.path);
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
          ElevatedButton.icon(
            icon: FaIcon(FontAwesomeIcons.fileExcel),
            label: Text(
              'Открыть отчёт',
            ),
            onPressed: () => context.read<ImporterBloc>().add(ImportEvent()),
          )
        ],
      ),
    );
  }
}
