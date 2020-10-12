import 'package:kres_requests2/data/java_process_executor.dart';
import 'package:kres_requests2/data/models/java_process_info.dart';
import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

import 'config_repository.dart';

class RequestsRepository {
  final AbstractRequestProcessor _requestProcessor;

  // TODO: Create module instead of calling constructors every time
  RequestsRepository(
    SettingsRepository settings,
    ConfigRepository configs,
  ) : _requestProcessor = RequestProcessorImpl(
          JavaProcessExecutor(
            javaHome: settings.javaPath,
            javaProcessInfo:
                JavaProcessInfo.fromMap(configs.getRequestsProcessInfoData()),
          ),
        );

  /// Checks that the request processor is ready for doing work
  Future<bool> isAvailable() => _requestProcessor.isAvailable();

  /// Prints all [worksheets] on [printerName]
  /// If [noLists] is `true` only order pages will be printed
  Future<OptionalData<bool>> printWorksheets(
          List<Worksheet> worksheets, String printerName, bool noLists) =>
      _requestProcessor.printWorksheets(worksheets, printerName, noLists);

  /// Exports all [worksheets] to PDF file to [destinationPath]
  Future<OptionalData> exportToPdf(
          List<Worksheet> worksheets, String destinationPath) =>
      _requestProcessor.exportToPdf(worksheets, destinationPath);

  /// Exports all [worksheets] (as lists) to Excel XLSX file to [destinationPath]
  Future<OptionalData> exportToXlsx(
          List<Worksheet> worksheets, String destinationPath) =>
      _requestProcessor.exportToXlsx(worksheets, destinationPath);

  /// Imports worksheet previously exported to XLS by Mega-billing app
  Future<OptionalData<Document>> importRequests(String filePath) =>
      _requestProcessor.importRequests(filePath);

  /// Gets all available printers that can handle document printing
  Future<OptionalData<List<String>>> listPrinters() =>
      _requestProcessor.listPrinters();
}
