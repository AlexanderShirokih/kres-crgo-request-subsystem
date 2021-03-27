import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';

class ImporterProcessorMissingException implements Exception {}

class RequestsRepository extends WorksheetImporterRepository {
  final AbstractRequestProcessor _requestProcessor;

  RequestsRepository(this._requestProcessor);

  /// Checks that the request processor is ready for doing work
  Future<bool> isAvailable() => _requestProcessor.isAvailable();

  /// Prints all [worksheets] on [printerName]
  /// If [noLists] is `true` only order pages will be printed
  Future<OptionalData<bool>> printWorksheets(
          List<Worksheet> worksheets, String printerName, bool noLists) =>
      _requestProcessor
          .printWorksheets(worksheets, printerName, noLists)
          .catchError((e, s) => OptionalData.ofError<bool>(e, s));

  /// Exports all [worksheets] to PDF file to [destinationPath]
  Future<OptionalData> exportToPdf(
          List<Worksheet> worksheets, String destinationPath) =>
      _requestProcessor
          .exportToPdf(worksheets, destinationPath)
          .catchError((e, s) => OptionalData.ofError(e, s));

  /// Exports all [worksheets] (as lists) to Excel XLSX file to [destinationPath]
  Future<OptionalData> exportToXlsx(
          List<Worksheet> worksheets, String destinationPath) =>
      _requestProcessor
          .exportToXlsx(worksheets, destinationPath)
          .catchError((e, s) => OptionalData.ofError(e, s));

  /// Imports worksheet previously exported to XLS by Mega-billing app
  @override
  Future<Document?> importDocument(String filePath) async {
    final isExists = await isAvailable();
    if (!isExists) throw ImporterProcessorMissingException();

    final importResult = await _requestProcessor.importRequests(filePath);
    if (importResult.hasError()) {
      throw importResult.error!;
    }

    return importResult.data;
  }

  /// Gets all available printers that can handle document printing
  Future<OptionalData<List<String>>> listPrinters() => _requestProcessor
      .listPrinters()
      .catchError((e, s) => OptionalData.ofError<List<String>>(e, s));
}
