import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:kres_requests2/core/process_result.dart';
import 'package:kres_requests2/data/request_entity.dart';
import 'package:kres_requests2/data/worksheet.dart';
import 'package:kres_requests2/data/document.dart';

abstract class AbstractRequestProcessor {
  const AbstractRequestProcessor();

  /// Checks that the request processor is ready for doing work
  Future<bool> isAvailable();

  /// Prints all [worksheets] on [printerName]
  /// If [noLists] is `true` only order pages will be printed
  Future<RequestsProcessResult<bool>> printWorksheets(
      List<Worksheet> worksheets, String printerName, bool noLists);

  /// Exports all [worksheets] to PDF file to [destinationPath]
  Future<RequestsProcessResult> exportToPdf(
      List<Worksheet> worksheets, String destinationPath);

  /// Imports worksheet previously exported to XLS by Mega-billing app
  Future<RequestsProcessResult<Document>> importRequests(String filePath);

  /// Gets all available printers that can handle document printing
  Future<RequestsProcessResult<List<String>>> listPrinters();
}

class RequestProcessorImpl extends AbstractRequestProcessor {
  final File _requestProcessorFile;

  const RequestProcessorImpl(this._requestProcessorFile)
      : assert(_requestProcessorFile != null);

  @override
  Future<bool> isAvailable() => _requestProcessorFile.exists();

  @override
  Future<RequestsProcessResult<List<String>>> listPrinters() =>
      Process.run(_requestProcessorFile.path, ['-list-printers']).then(
        (result) => _decodeProcessResult<List<String>>(
            result,
            (d) => (d as List<dynamic>).cast<String>(),
            'Ошибка поиска служб печати!'),
      );

  @override
  Future<RequestsProcessResult<bool>> printWorksheets(
      List<Worksheet> worksheets, String printerName, bool noLists) async {
    final tempFile = await _saveToTempFile(worksheets);

    return await Process.run(_requestProcessorFile.path,
            ['-print', tempFile.path, printerName, if (noLists) '-no-lists'])
        .then(
          (result) => _decodeProcessResult(
              result, (d) => d as bool, 'Ошибка отправки задания!'),
        )
        .whenComplete(() => tempFile.delete());
  }

  @override
  Future<RequestsProcessResult> exportToPdf(
      List<Worksheet> worksheets, String destinationPath) async {
    final tempFile = await _saveToTempFile(worksheets);

    return await Process.run(_requestProcessorFile.path,
            ['-pdf', tempFile.path, destinationPath])
        .then(
          (result) =>
              _decodeProcessResult(result, (d) => "", 'Ошибка экспорта!'),
        )
        .whenComplete(() => tempFile.delete());
  }

  @override
  Future<RequestsProcessResult<Document>> importRequests(String filePath) =>
      Process.run(_requestProcessorFile.path, ['-parse', filePath])
          .then((ProcessResult result) => _decodeProcessResult(
                result,
                (d) => Document(worksheets: [
                  Worksheet(
                    name: _getWorksheetName(filePath),
                    requests: (d as List<dynamic>)
                        .map((e) => RequestEntity.fromJson(e))
                        .toList(),
                  )
                ]),
                "Parsing error!",
              ));

  Future<File> _saveToTempFile(List<Worksheet> worksheets) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile =
        File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}');

    final encoded = await Future.microtask(
      () => json.encode(worksheets.map((w) => w.toJson()).toList()),
    );

    return await tempFile.writeAsString(encoded);
  }

  RequestsProcessResult<T> _decodeProcessResult<T>(ProcessResult result,
          T Function(dynamic) dataConsumer, String errorMsg) =>
      result.exitCode == 0
          ? RequestsProcessResult.fromJson(
              jsonDecode(result.stdout), dataConsumer)
          : RequestsProcessResult(error: '$errorMsg\n${result.stderr}');

  String _getWorksheetName(String filePath) =>
      path.basenameWithoutExtension(filePath);
}
