import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/domain/document_service.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/models/request_set.dart';

import 'package:kres_requests2/data/process_executor.dart';

abstract class AbstractRequestProcessor {
  const AbstractRequestProcessor();

  /// Checks that the request processor is ready for doing work
  Future<bool> isAvailable();

  /// Prints all [worksheets] on [printerName]
  /// If [noLists] is `true` only order pages will be printed
  Future<OptionalData<bool>> printWorksheets(
      List<RequestSet> worksheets, String printerName, bool noLists);

  /// Exports all [worksheets] to PDF file to [destinationPath]
  Future<OptionalData> exportToPdf(
      List<RequestSet> worksheets, String destinationPath);

  /// Exports all [worksheets] (as lists) to Excel XLSX file to [destinationPath]
  Future<OptionalData> exportToXlsx(
      List<RequestSet> worksheets, String destinationPath);

  /// Imports worksheet previously exported to XLS by Mega-billing app
  Future<OptionalData<DocumentService>> importRequests(String filePath);

  /// Gets all available printers that can handle document printing
  Future<OptionalData<List<String>>> listPrinters();
}

class RequestProcessorImpl extends AbstractRequestProcessor {
  final ProcessExecutor _requestsProcessExecutor;

  const RequestProcessorImpl(this._requestsProcessExecutor)
      : assert(_requestsProcessExecutor != null);

  @override
  Future<bool> isAvailable() => _requestsProcessExecutor.isAvailable();

  @override
  Future<OptionalData<List<String>>> listPrinters() =>
      _requestsProcessExecutor.runProcess(['-list-printers']).then(
        (result) => _decodeProcessResult<List<String>>(
            result,
            (d) => (d as List<dynamic>).cast<String>(),
            'Ошибка поиска служб печати!'),
      );

  @override
  Future<OptionalData<bool>> printWorksheets(
      List<RequestSet> worksheets, String printerName, bool noLists) async {
    // TODO: Unimplemented
    final tempFile = File('error!');

    return await _requestsProcessExecutor
        .runProcess(
            ['-print', tempFile.path, printerName, if (noLists) '-no-lists'])
        .then(
          (result) => _decodeProcessResult<bool>(
              result, (d) => d as bool, 'Ошибка отправки задания!'),
        )
        .whenComplete(() => tempFile.delete());
  }

  @override
  Future<OptionalData> exportToPdf(
          List<RequestSet> worksheets, String destinationPath) =>
      _doExport(worksheets, "pdf", destinationPath);

  @override
  Future<OptionalData> exportToXlsx(
          List<RequestSet> worksheets, String destinationPath) =>
      _doExport(worksheets, "xlsx", destinationPath);

  Future<OptionalData> _doExport(List<RequestSet> worksheets, String format,
      String destinationPath) async {
    // TODO: Unimplemented
    final tempFile = File('error!');

    return await _requestsProcessExecutor
        .runProcess(['-export-$format', tempFile.path, destinationPath])
        .then(
          (result) =>
              _decodeProcessResult(result, (d) => "", 'Ошибка экспорта!'),
        )
        .whenComplete(() => tempFile.delete());
  }

  @override
  Future<OptionalData<DocumentService>> importRequests(String filePath) =>
      _requestsProcessExecutor.runProcess(['-parse', filePath]).then(
          (ProcessResult result) => _decodeProcessResult<DocumentService>(
                result,
                // TODO: Unimplemented
                (d) => throw UnimplementedError(),
                "Parsing error!",
              ));

  OptionalData<T> _decodeProcessResult<T>(ProcessResult result,
          T Function(dynamic) dataConsumer, String errorMsg) =>
      result.exitCode == 0
          ? _createFromProcessResult(jsonDecode(result.stdout), dataConsumer)
          : OptionalData<T>(error: ErrorWrapper(errorMsg, result.stderr));

  OptionalData<T> _createFromProcessResult<T>(
          Map<String, dynamic> json, T Function(dynamic) resultBuilder) =>
      OptionalData(
          data: json['data'] != null ? resultBuilder(json['data']) : null,
          error: ErrorWrapper(json['error'], json['stackTrace']));
}
