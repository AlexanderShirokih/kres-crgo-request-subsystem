import 'package:kres_requests2/domain/request_processor.dart';
import 'package:kres_requests2/domain/models.dart';

/// A class responsible for exporting and printing documents
class RequestsExportService {
  final AbstractRequestProcessor _requestProcessor;

  RequestsExportService(this._requestProcessor);

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

  /// Gets all available printers that can handle document printing
  Future<List<String>> listPrinters() => _requestProcessor.listPrinters();
}
