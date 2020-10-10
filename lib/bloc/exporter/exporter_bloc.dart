import 'dart:async';

import 'package:kres_requests2/core/process_result.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/data/worksheet.dart';
import 'package:kres_requests2/core/request_processor.dart';

part 'exporter_event.dart';

part 'exporter_state.dart';

class ExporterBloc extends Bloc<ExporterEvent, ExporterState> {
  final SettingsRepository settings;
  final List<Worksheet> worksheets;
  final Future<String> Function() fileChooser;

  final AbstractRequestProcessor _requestProcessor;

  ExporterBloc({
    @required this.settings,
    @required this.worksheets,
    this.fileChooser,
  })  : assert(settings != null),
        assert(worksheets != null),
        _requestProcessor =
            RequestProcessorImpl(settings.requestsProcessorExecutable.absolute),
        super(ExporterIdle()) {
    if (fileChooser != null)
      add(ExporterShowSaveDialogEvent());
    else
      add(ExporterShowPrintersListEvent());
  }

  @override
  Stream<ExporterState> mapEventToState(ExporterEvent event) async* {
    if (event is ExporterInitialEvent) {
      if (!await _requestProcessor.isAvailable()) {
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
      yield ExporterErrorState(event.exception);
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    add(
      ExporterErrorEvent(
        RequestsProcessException(error.toString(), stackTrace.toString()),
      ),
    );
    super.onError(error, stackTrace);
  }

  Stream<ExporterState> _listPrinters() async* {
    yield ExporterIdle(message: 'Поиск доступных принтеров');

    final result = await _requestProcessor.listPrinters();

    if (result.hasError()) {
      yield ExporterErrorState(result.createException());
    } else {
      final availablePrinters = result.data;
      final preferred = availablePrinters.contains(settings.lastUsedPrinter)
          ? settings.lastUsedPrinter
          : null;

      yield ExporterListPrintersState(
        preferred,
        availablePrinters,
      );
    }
  }

  Stream<ExporterState> _printDocument(
      String printerName, bool noLists) async* {
    settings.lastUsedPrinter = printerName;

    yield ExporterIdle(
        message: 'Создание документа и отправка задания на печать');

    final result = await _requestProcessor.printWorksheets(
        worksheets, printerName, noLists);

    if (result.hasError()) {
      yield ExporterErrorState(result.createException());
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

    final result = await _requestProcessor.exportToPdf(worksheets, filePath);

    if (result.hasError()) {
      yield ExporterErrorState(result.createException());
    } else {
      yield ExporterClosingState(isCompleted: true);
    }
  }
}
