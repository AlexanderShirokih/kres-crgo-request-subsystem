import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/export_service.dart';

part 'exporter_event.dart';
part 'exporter_state.dart';

/// BLoC for exporting documents
class ExporterBloc extends Bloc<ExporterEvent, ExporterState> {
  /// Export service instance
  final ExportService service;

  ExporterBloc({required this.service}) : super(ExporterIdle());

  @override
  Stream<ExporterState> mapEventToState(ExporterEvent event) async* {
    if (event is _ExporterStartEvent) {
      if (!await service.isAvailable()) {
        yield ExporterMissingState();
        return;
      }
    }

    if (event is ExportEvent) {
      yield* _doExport(event);
    } else if (event is ShowPrintersListEvent) {
      yield* _listPrinters();
    } else if (event is PrintDocumentEvent) {
      yield* _printDocument(event);
    } else if (event is _ExporterErrorEvent) {
      yield ExporterErrorState(
        event.error.toString(),
        event.stackTrace.toString(),
      );
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    add(_ExporterErrorEvent(error.toString(), stackTrace));
    super.onError(error, stackTrace);
  }

  Stream<ExporterState> _listPrinters() async* {
    yield ExporterIdle(message: 'Поиск доступных принтеров');

    try {
      final printersList = await service.listPrinters();

      yield ExporterListPrintersState(
        printersList.preferred,
        printersList.available,
      );
    } on ExportServiceException catch (e) {
      yield ExporterErrorState(e.error, e.stackTrace);
    }
  }

  Stream<ExporterState> _printDocument(PrintDocumentEvent event) async* {
    yield ExporterIdle(
        message: 'Создание документа и отправка задания на печать');

    try {
      await service.printDocument(
        event.document,
        event.printerName,
        event.noLists,
      );

      yield ExporterClosingState(isCompleted: true);
    } on ExportServiceException catch (e) {
      yield ExporterErrorState(e.error, e.stackTrace);
    }
  }

  Stream<ExporterState> _doExport(ExportEvent event) {
    return service
        .exportDocument(event.document, event.exportFormat)
        .map((state) {
      switch (state) {
        case ExportState.pickingFile:
          return ExporterIdle(message: 'Ожидание выбора файла');
        case ExportState.exporting:
          return ExporterIdle(message: 'Экспорт файла');
        case ExportState.done:
          return ExporterClosingState(isCompleted: true);
        case ExportState.cancelled:
          return ExporterClosingState(isCompleted: false);
      }
    }).transform(
      StreamTransformer.fromHandlers(handleError: (e, s, sink) {
        if (e is ExportServiceException) {
          sink.add(ExporterErrorState(e.error, e.stackTrace));
        } else {
          sink.addError(e, s);
        }
      }),
    );
  }
}
