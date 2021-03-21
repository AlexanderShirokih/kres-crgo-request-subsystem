import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/exporter/exporter_bloc.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:path/path.dart' as path;

extension on ExportFormat {
  String formatExtension() {
    switch (this) {
      case ExportFormat.Pdf:
        return "pdf";
      case ExportFormat.Excel:
        return "xlsx";
    }
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
  ) : suggestedExportBasename =
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
            repositoryModule: context.watch<RepositoryModule>(),
            fileChooser: _showFileChooser,
            worksheets: worksheets,
          ),
          child: Builder(
            builder: (context) => BlocConsumer<ExporterBloc, ExporterState>(
              builder: (context, state) {
                if (state is ExporterErrorState) {
                  return ErrorView(
                    errorDescription: state.error.error.toString(),
                    stackTrace: state.error.stackTrace,
                  );
                }
                if (state is ExporterIdle) {
                  return LoadingView(state.message!);
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

  Future<String?> _showFileChooser() async {
    final extension = exportFormat.formatExtension();
    final dotExtension = '.$extension';
    final res = await getSavePath(
      suggestedName: _correctExtension(suggestedExportBasename, dotExtension),
      confirmButtonText: 'Сохранить',
      acceptedTypeGroups: [
        XTypeGroup(
          label: "Документ ${extension.toUpperCase()}",
          extensions: [extension],
        )
      ],
    );

    if (res == null) {
      return null;
    }

    return _correctExtension(res, dotExtension);
  }

  String _correctExtension(String filePath, String ext) {
    if (path.extension(filePath) != ext) return '$filePath$ext';
    return filePath;
  }
}
