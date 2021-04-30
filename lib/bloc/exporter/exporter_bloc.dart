import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/domain/exchange/requests_export_service.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

part 'exporter_event.dart';

part 'exporter_state.dart';

/// Describes supported export formats
enum ExportFormat { pdf, excel }

/// BLoC for exporting documents
class ExporterBloc extends Bloc<ExporterEvent, ExporterState> {
  /// Exporting document
  final Document document;

  /// File picker function
  final Future<String?> Function()? fileChooser;

  /// Target export format
  final ExportFormat? exportFormat;

  /// Requests repository for handling export/print actions
  final RequestsExportService requestsService;

  /// Settings repository for updating preferred printer name
  final SettingsRepository settingsRepository;

  ExporterBloc({
    required this.requestsService,
    required this.settingsRepository,
    required this.document,
    this.exportFormat,
    this.fileChooser,
  }) : super(ExporterIdle()) {
    if (fileChooser != null)
      add(_ExporterShowSaveDialogEvent());
    else
      add(ExporterShowPrintersListEvent());
  }

  @override
  Stream<ExporterState> mapEventToState(ExporterEvent event) async* {
    if (event is _ExporterInitialEvent) {
      if (!await requestsService.isAvailable()) {
        yield ExporterMissingState();
        return;
      }
    }

    if (event is _ExporterShowSaveDialogEvent) {
      yield* _doExport();
    } else if (event is ExporterShowPrintersListEvent) {
      yield* _listPrinters();
    } else if (event is ExporterPrintDocumentEvent) {
      yield* _printDocument(event.printerName, event.noLists);
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
      final availablePrinters = await requestsService.listPrinters();
      final preferred =
          availablePrinters.contains(settingsRepository.lastUsedPrinter)
              ? await settingsRepository.lastUsedPrinter
              : null;

      yield ExporterListPrintersState(
        preferred,
        availablePrinters,
      );
    } on RequestProcessorError catch (e) {
      yield ExporterErrorState(e.error, e.stackTrace);
    } catch (e, s) {
      yield ExporterErrorState(e.toString(), s.toString());
    }
  }

  Stream<ExporterState> _printDocument(
      String printerName, bool noLists) async* {
    await settingsRepository.setLastUsedPrinter(printerName);

    yield ExporterIdle(
        message: 'Создание документа и отправка задания на печать');

    try {
      await requestsService.printDocument(document, printerName, noLists);
      yield ExporterClosingState(isCompleted: true);
    } on RequestProcessorError catch (e) {
      yield ExporterErrorState(e.error, e.stackTrace);
    } catch (e, s) {
      yield ExporterErrorState(e.toString(), s.toString());
    }
  }

  Stream<ExporterState> _doExport() async* {
    yield ExporterIdle(message: 'Ожидание выбора файла');

    if (fileChooser == null) {
      throw 'No file chooser passed!';
    }

    final filePath = await fileChooser!();
    if (filePath == null) {
      yield ExporterClosingState(isCompleted: false);
      return;
    }

    yield ExporterIdle(message: 'Экспорт файла');

    try {
      await runExporter(filePath);
      yield ExporterClosingState(isCompleted: true);
    } on RequestProcessorError catch (e) {
      yield ExporterErrorState(e.error, e.stackTrace);
    } catch (e, s) {
      yield ExporterErrorState(e.toString(), s.toString());
    }
  }

  Future<void> runExporter(String savePath) {
    switch (exportFormat) {
      case ExportFormat.pdf:
        return requestsService.exportToPdf(document, savePath);
      case ExportFormat.excel:
        return requestsService.exportToXlsx(document, savePath);
      default:
        throw ('Cannot run exporter without export format');
    }
  }
}
