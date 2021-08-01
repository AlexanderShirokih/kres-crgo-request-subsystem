import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/presentation/bloc/importer/importer_bloc.dart';

import 'base_importer_screen.dart';

class CountersImportScreen extends ImporterScreen {
  final Document? mergeTarget;

  const CountersImportScreen({
    Key? key,
    this.mergeTarget,
  }) : super(
          key: key,
          title: 'Импорт списка счетчиков на замену',
        );

  @override
  Widget buildIdleView(BuildContext context) => Center(
        heightFactor: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '1. Подготовьте отчёт со списком счётчиков в формате XLSX (Excel 2007-365).\n'
              '2. Расположите данных в колонках согласно примеру\n'
              '3. Нажмите Открыть отчёт и выберите сохранённый файл',
              style: Theme.of(context).textTheme.headline4,
            ),
            const SizedBox(height: 42.0),
            Image.asset('assets/images/counters_import_template.png'),
            const SizedBox(height: 42.0),
            ElevatedButton.icon(
              icon: const FaIcon(FontAwesomeIcons.fileExcel),
              label: const Text('Открыть отчёт'),
              onPressed: () => context
                  .read<ImporterBloc>()
                  .add(ImportEvent(mergeTarget: mergeTarget)),
            )
          ],
        ),
      );
}
