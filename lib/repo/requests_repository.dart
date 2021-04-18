import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';

/// Exception class used when request processor module is missing
class ImporterProcessorMissingException implements Exception {}

/// A class responsible for exporting and printing documents
class RequestsRepository extends WorksheetImporterRepository {
  final AbstractRequestProcessor _requestProcessor;

  RequestsRepository(this._requestProcessor);

  /// Checks that the request processor is ready for doing work
  Future<bool> isAvailable() => _requestProcessor.isAvailable();

  /// Prints all worksheet in the [document] on printer named [printerName]
  /// If [noLists] is `true` only order pages will be printed
  Future<bool> printDocument(
          Document document, String printerName, bool noLists) =>
      _requestProcessor.printDocument(document, printerName, noLists);

  /// Exports all worksheets in the [document] to PDF file and saves it
  /// at the [destinationPath]
  Future<void> exportToPdf(Document document, String destinationPath) =>
      _requestProcessor.exportToPdf(document, destinationPath);

  /// Exports all worksheets (as lists) in the [document] to Excel XLSX file and
  /// saves it at the [destinationPath]
  Future<void> exportToXlsx(Document document, String destinationPath) =>
      _requestProcessor.exportToXlsx(document, destinationPath);

  /// Imports document previously exported to XLS by Mega-billing app
  @override
  Future<Document?> importDocument(String filePath) async {
    final isExists = await isAvailable();
    if (!isExists) throw ImporterProcessorMissingException();

    return await _requestProcessor.importRequests(filePath);
  }

  /// Gets all available printers that can handle document printing
  Future<List<String>> listPrinters() => _requestProcessor.listPrinters();
}
