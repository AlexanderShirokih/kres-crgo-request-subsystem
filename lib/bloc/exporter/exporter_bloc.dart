import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models/optional_data.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

part 'exporter_event.dart';
part 'exporter_state.dart';

enum ExportFormat { Pdf, Excel }

class ExporterBloc extends Bloc<ExporterEvent, ExporterState> {
  final Document document;
  final Future<String?> Function()? fileChooser;
  final ExportFormat? exportFormat;

  final RequestsRepository _requestsRepository;
  final SettingsRepository _settingsRepository;

  ExporterBloc({
    required RepositoryModule repositoryModule,
    required this.document,
    this.exportFormat,
    this.fileChooser,
  })  : _requestsRepository = repositoryModule.getRequestsRepository(),
        _settingsRepository = repositoryModule.getSettingsRepository(),
        super(ExporterIdle()) {
    if (fileChooser != null)
      add(ExporterShowSaveDialogEvent());
    else
      add(ExporterShowPrintersListEvent());
  }

  @override
  Stream<ExporterState> mapEventToState(ExporterEvent event) async* {
    if (event is ExporterInitialEvent) {
      if (!await _requestsRepository.isAvailable()) {
        yield ExporterMissingState();
        return;
      }
    }

    if (event is ExporterShowSaveDialogEvent) {
      yield* _doExport();
    } else if (event is ExporterShowPrintersListEvent) {
      yield* _listPrinters();
    } else if (event is ExporterPrintDocumentEvent) {
      yield* _printDocument(event.printerName, event.noLists);
    } else if (event is ExporterErrorEvent) {
      yield ExporterErrorState(
        event.error.error.toString(),
        event.error.stackTrace.toString(),
      );
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    add(ExporterErrorEvent(ErrorWrapper(error, stackTrace)));
    super.onError(error, stackTrace);
  }

  Stream<ExporterState> _listPrinters() async* {
    yield ExporterIdle(message: 'Поиск доступных принтеров');

    try {
      final availablePrinters = await _requestsRepository.listPrinters();
      final preferred =
          availablePrinters.contains(_settingsRepository.lastUsedPrinter)
              ? _settingsRepository.lastUsedPrinter
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
    _settingsRepository.lastUsedPrinter = printerName;

    yield ExporterIdle(
        message: 'Создание документа и отправка задания на печать');

    try {
      await _requestsRepository.printDocument(document, printerName, noLists);
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
      await _runExporter(filePath);
      yield ExporterClosingState(isCompleted: true);
    } on RequestProcessorError catch (e) {
      yield ExporterErrorState(e.error, e.stackTrace);
    } catch (e, s) {
      yield ExporterErrorState(e.toString(), s.toString());
    }
  }

  Future<void> _runExporter(String savePath) {
    switch (exportFormat) {
      case ExportFormat.Pdf:
        return _requestsRepository.exportToPdf(document, savePath);
      case ExportFormat.Excel:
        return _requestsRepository.exportToXlsx(document, savePath);
      default:
        throw ("Cannot run exporter without export format");
    }
  }
}
