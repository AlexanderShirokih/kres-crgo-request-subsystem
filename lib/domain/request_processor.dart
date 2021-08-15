import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/editor/json_document_factory.dart';
import 'package:kres_requests2/domain/editor/decoding_pipeline.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/process_executor.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Responsible for exporting and printing documents
abstract class AbstractRequestProcessor {
  const AbstractRequestProcessor();

  /// Checks that the request processor is ready for doing work
  Future<bool> isAvailable();

  /// Prints all worksheet in the [document] on printer named [printerName]
  /// If [noLists] is `true` only order pages will be printed
  Future<bool> printDocument(
      Document document, String printerName, bool noLists);

  /// Exports all worksheets in the [document] to PDF file and saves it
  /// at the [destinationPath]
  Future<void> exportToPdf(Document document, String destinationPath);

  /// Exports all worksheets (as lists) in the [document] to Excel XLSX file and
  /// saves it at the [destinationPath]
  Future<void> exportToXlsx(Document document, String destinationPath);

  /// Imports worksheet previously exported to XLS by Mega-billing app
  Future<Document> importRequests(String filePath);

  /// Gets all available printers that can handle document printing
  Future<List<String>> listPrinters();
}

class MegaBillingRequestProcessorImpl extends AbstractRequestProcessor {
  final ProcessExecutor _requestsProcessExecutor;
  final DecodingPipeline _megaBillingPipeline;
  final DocumentSaver _saver;

  const MegaBillingRequestProcessorImpl(
    this._requestsProcessExecutor,
    this._megaBillingPipeline,
    this._saver,
  );

  @override
  Future<bool> isAvailable() => _requestsProcessExecutor.isAvailable();

  @override
  Future<List<String>> listPrinters() {
    return _requestsProcessExecutor.runProcess(['-list-printers']).then(
      (result) => _decodeProcessResult<List<String>>(
          result,
          (d) => (d as List<dynamic>).cast<String>(),
          'Ошибка поиска служб печати!'),
    );
  }

  @override
  Future<bool> printDocument(
      Document document, String printerName, bool noLists) async {
    final tempFile = await _saveToTempFile(document);

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
  Future<void> exportToPdf(Document document, String destinationPath) {
    return _doExport(document, "pdf", destinationPath);
  }

  @override
  Future<void> exportToXlsx(Document document, String destinationPath) {
    return _doExport(document, "xlsx", destinationPath);
  }

  Future<void> _doExport(
      Document document, String format, String destinationPath) async {
    final tempFile = await _saveToTempFile(document);

    final result = await _requestsProcessExecutor
        .runProcess(['-export-$format', tempFile.path, destinationPath]);

    try {
      await _decodeProcessResult<void>(result, (_) {}, 'Ошибка экспорта!');
    } finally {
      await tempFile.delete();
    }
  }

  @override
  Future<Document> importRequests(String filePath) async {
    final processResult =
        await _requestsProcessExecutor.runProcess(['-parse', filePath]);

    return _decodeProcessResult<Document>(
      processResult,
      (requests) {
        final factory = JsonDocumentFactory(
          {
            'worksheets': [
              {
                'name': path.basenameWithoutExtension(filePath),
                'requests': requests,
              }
            ],
          },
          pipeline: _megaBillingPipeline,
        );

        return factory.createDocument();
      },
      "Parsing error!",
    );
  }

  Future<File> _saveToTempFile(Document document) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile =
        File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}');

    await _saver.store(document, tempFile);

    return tempFile;
  }

  Future<T> _decodeProcessResult<T>(ProcessResult result,
      FutureOr<T> Function(dynamic) dataConsumer, String errorMsg) async {
    if (result.exitCode == 0) {
      // Process finishes successfully
      return await Future.microtask(
        () => _createFromProcessResult(jsonDecode(result.stdout), dataConsumer),
      );
    }

    throw RequestProcessorError(errorMsg, result.stderr);
  }

  FutureOr<T> _createFromProcessResult<T>(
      Map<String, dynamic> json, FutureOr<T> Function(dynamic) resultBuilder) {
    final data = json['data'];

    if (data != null) {
      return resultBuilder(data);
    }

    throw RequestProcessorError(json['error'], json['stackTrace']);
  }
}

class RequestProcessorError extends Equatable implements Exception {
  final String error;
  final String stackTrace;

  const RequestProcessorError(this.error, this.stackTrace);

  @override
  List<Object?> get props => [error, stackTrace];
}
