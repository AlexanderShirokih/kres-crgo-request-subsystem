import 'package:file_chooser/file_chooser.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:kres_requests2/data/worksheet.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:path/path.dart' as path;

import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/bloc/exporter/exporter_bloc.dart';

class ExportToPDFDialog extends StatelessWidget {
  final List<Worksheet> worksheets;
  final String suggestedExportBasename;

  const ExportToPDFDialog(this.worksheets,
      this.suggestedExportBasename,)
      : assert(worksheets != null),
        assert(suggestedExportBasename != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Экспорт в PDF'),
      content: Container(
        width: 300.0,
        height: 300.0,
        child: BlocProvider.value(
          value: ExporterBloc(
            settings: context.repository<SettingsRepository>(),
            fileChooser: _showFileChooser,
            worksheets: worksheets,
          ),
          child: Builder(
            builder: (context) =>
                BlocConsumer<ExporterBloc, ExporterState>(
                  builder: (context, state) {
                    if (state is ExporterErrorState &&
                        state.exception != null) {
                      return ErrorView(
                        errorDescription: state.exception.error,
                        stackTrace: state.exception.stackTrace,
                      );
                    }
                    if (state is ExporterIdle) {
                      return LoadingView(state.message);
                    } else
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                  },
                  listener: (context, state) {
                    if (state is ExporterClosingState) {
                      Navigator.of(context)
                          .pop(state.isCompleted ? 'Экспорт завершён' : null);
                    } else if (state is ExporterMissingState) {
                      Navigator.of(context)
                          .pop('Ошибка: Модуль экспорта файлов отсутcтвует');
                    }
                  },
                ),
          ),
        ),
      ),
    );
  }

  Future<String> _showFileChooser() async {
    final res = await showSavePanel(
      suggestedFileName: path.setExtension(suggestedExportBasename, '.pdf'),
      confirmButtonText: 'Сохранить',
      allowedFileTypes: [
        FileTypeFilterGroup(
          label: "Документ PDF",
          fileExtensions: ["pdf"],
        )
      ],
    );

    if (res.canceled) return null;

    final exportPath = res.paths[0];
    if (path.extension(exportPath) != '.pdf') return '$exportPath.pdf';
    return exportPath;
  }
}
