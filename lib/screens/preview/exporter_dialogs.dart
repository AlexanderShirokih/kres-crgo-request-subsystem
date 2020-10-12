import 'package:file_chooser/file_chooser.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:kres_requests2/repo/config_repository.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:path/path.dart' as path;

import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/bloc/exporter/exporter_bloc.dart';

extension on ExportFormat {
  String formatExtension() {
    switch (this) {
      case ExportFormat.Pdf:
        return "pdf";
      case ExportFormat.Excel:
        return "xlsx";
    }
    throw ('Unknown export format!');
  }
}

class ExporterDialog extends StatelessWidget {
  final List<Worksheet> worksheets;
  final String suggestedExportBasename;
  final ExportFormat exportFormat;

  ExporterDialog(
    this.exportFormat,
    this.worksheets,
    String Function(String) suggestedNameProvider,
  )   : assert(exportFormat != null),
        assert(worksheets != null),
        assert(suggestedNameProvider != null),
        suggestedExportBasename =
            suggestedNameProvider('.${exportFormat.formatExtension()}');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Экспорт в ${exportFormat.formatExtension().toUpperCase()}'),
      content: Container(
        width: 300.0,
        height: 300.0,
        child: BlocProvider.value(
          value: ExporterBloc(
            exportFormat: exportFormat,
            settings: context.repository<SettingsRepository>(),
            fileChooser: _showFileChooser,
            worksheets: worksheets,
            requestsRepository: RequestsRepository(
              context.repository<SettingsRepository>(),
              context.repository<ConfigRepository>(),
            ),
          ),
          child: Builder(
            builder: (context) => BlocConsumer<ExporterBloc, ExporterState>(
              builder: (context, state) {
                if (state is ExporterErrorState && state.error != null) {
                  return ErrorView(
                    errorDescription: state.error.error,
                    stackTrace: state.error.stackTrace,
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
    final extension = exportFormat.formatExtension();
    final dotExtension = '.$extension';
    final res = await showSavePanel(
      suggestedFileName:
          _correctExtension(suggestedExportBasename, dotExtension),
      confirmButtonText: 'Сохранить',
      allowedFileTypes: [
        FileTypeFilterGroup(
          label: "Документ ${extension.toUpperCase()}",
          fileExtensions: [extension],
        )
      ],
    );

    if (res.canceled) return null;

    return _correctExtension(res.paths[0], dotExtension);
  }

  String _correctExtension(String filePath, String ext) {
    if (path.extension(filePath) != ext) return '$filePath$ext';
    return filePath;
  }
}
