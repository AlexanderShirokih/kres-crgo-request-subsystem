import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/presentation/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/presentation/importer/base_importer_screen.dart';

/// Mega-billing XLS request files import wizard
class RequestsImporterScreen extends ImporterScreen {
  const RequestsImporterScreen() : super(title: 'Импорт заявок');

  @override
  Widget buildIdleView(BuildContext context) {
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
