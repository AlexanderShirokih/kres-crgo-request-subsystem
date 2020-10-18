import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

part 'exporter_event.dart';

part 'exporter_state.dart';

enum ExportFormat { Pdf, Excel }

class ExporterBloc extends Bloc<ExporterEvent, ExporterState> {
  final List<Worksheet> worksheets;
  final Future<String> Function() fileChooser;
  final ExportFormat exportFormat;

  final RequestsRepository _requestsRepository;
  final SettingsRepository _settingsRepository;

  ExporterBloc({
    @required this.worksheets,
    @required RepositoryModule repositoryModule,
    this.exportFormat,
    this.fileChooser,
  })
      :assert(worksheets != null),
        assert(repositoryModule != null),
        _requestsRepository = repositoryModule.getRequestsRepository(),
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
      yield ExporterErrorState(event.error);
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    add(ExporterErrorEvent(
        ErrorWrapper(error.toString(), stackTrace.toString())));
    super.onError(error, stackTrace);
  }

  Stream<ExporterState> _listPrinters() async* {
    yield ExporterIdle(message: 'Поиск доступных принтеров');

    final result =
    await _requestsRepository.listPrinters();

    if (result.hasError()) {
      yield ExporterErrorState(result.error);
    } else {
      final availablePrinters = result.data;
      final preferred = availablePrinters.contains(
          _settingsRepository.lastUsedPrinter)
          ? _settingsRepository.lastUsedPrinter
          : null;

      yield ExporterListPrintersState(
        preferred,
        availablePrinters,
      );
    }
  }

  Stream<ExporterState> _printDocument(String printerName,
      bool noLists) async* {
    _settingsRepository.lastUsedPrinter = printerName;

    yield ExporterIdle(
        message: 'Создание документа и отправка задания на печать');

    final result = await _requestsRepository.printWorksheets(
        worksheets, printerName, noLists);

    if (result.hasError()) {
      yield ExporterErrorState(result.error);
    } else {
      yield ExporterClosingState(isCompleted: true);
    }
  }

  Stream<ExporterState> _doExport() async* {
    yield ExporterIdle(message: 'Ожидание выбора файла');

    final filePath = await fileChooser();
    if (filePath == null) {
      yield ExporterClosingState(isCompleted: false);
      return;
    }

    yield ExporterIdle(message: 'Экспорт файла');

    final result = await _runExporter(filePath);

    if (result.hasError()) {
      yield ExporterErrorState(result.error);
    } else {
      yield ExporterClosingState(isCompleted: true);
    }
  }

  Future<OptionalData> _runExporter(String savePath) {
    switch (exportFormat) {
      case ExportFormat.Pdf:
        return _requestsRepository.exportToPdf(worksheets, savePath);
      case ExportFormat.Excel:
        return _requestsRepository.exportToXlsx(worksheets, savePath);
    }
    throw ('Unknown exporter format');
  }
}
