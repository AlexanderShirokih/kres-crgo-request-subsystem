import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/exporter/exporter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:path/path.dart' as path;

/// Extension for getting file extension string from [ExportFormat].
extension on ExportFormat {
  String formatExtension() {
    switch (this) {
      case ExportFormat.pdf:
        return "pdf";
      case ExportFormat.excel:
        return "xlsx";
    }
  }
}

/// Opens file chooser dialog for exporting file to external formats
class ExporterDialog extends StatelessWidget {
  /// Exporting document
  final Document document;

  /// Target export format
  final ExportFormat exportFormat;

  final String suggestedExportBasename;

  ExporterDialog(
    this.exportFormat,
    this.document,
  ) : suggestedExportBasename =
            '${document.suggestedName}.${exportFormat.formatExtension()}';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Экспорт в ${exportFormat.formatExtension().toUpperCase()}'),
      content: Container(
        width: 300.0,
        height: 300.0,
        child: BlocProvider(
          create: (_) => ExporterBloc(
            exportFormat: exportFormat,
            requestsService: Modular.get(),
            settingsRepository: Modular.get(),
            fileChooser: _showFileChooser,
            document: document,
          ),
          child: Builder(
            builder: (context) => BlocConsumer<ExporterBloc, ExporterState>(
              builder: (context, state) {
                if (state is ExporterErrorState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ErrorView(
                          errorDescription: state.error,
                          stackTrace: StackTrace.fromString(state.stackTrace),
                        ),
                      ),
                      BackButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                            'Ошибка экспорта: ${state.error}',
                          );
                        },
                      ),
                    ],
                  );
                }
                if (state is ExporterIdle) {
                  return LoadingView(state.message ?? '...');
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
      initialDirectory: document.currentSavePath?.parent.absolute.path,
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
