import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/presentation/bloc/exporter/exporter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/presentation/common.dart';

/// Opens file chooser dialog for exporting file to external formats
class ExporterDialog extends StatelessWidget {
  /// Target export format
  final ExportFormat exportFormat;

  final Document document;

  ExporterDialog(this.exportFormat, this.document);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Экспорт в ${exportFormat.extension().toUpperCase()}'),
      content: Container(
        width: 300.0,
        height: 300.0,
        child: BlocProvider(
          create: (_) => Modular.get<ExporterBloc>()
            ..add(ExportEvent(exportFormat, document)),
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
}
