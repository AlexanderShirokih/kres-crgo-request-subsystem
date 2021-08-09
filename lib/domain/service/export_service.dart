import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/repository/settings_repository.dart';
import 'package:kres_requests2/domain/request_processor.dart';
import 'package:kres_requests2/domain/service/export_file_chooser.dart';
import 'package:kres_requests2/domain/service/requests_export_service.dart';

/// Exception used by [ExportService] to throw when some error happened.
class ExportServiceException extends Equatable implements Exception {
  /// An error description
  final String error;

  // A stack trace string
  final String stackTrace;

  const ExportServiceException(this.error, this.stackTrace);

  @override
  List<Object?> get props => [error, stackTrace];
}

/// Service responsible for printing and exporting documents
class ExportService {
  /// Requests repository for handling export/print actions
  final RequestsExportService _requestsService;

  /// Settings repository for updating preferred printer name
  final SettingsRepository _settingsRepository;

  final ExportFileChooser _fileSelector;

  const ExportService(
    this._requestsService,
    this._settingsRepository,
    this._fileSelector,
  );

  /// Returns a list of available printers as [PrintersList].
  /// Throws [ExportServiceException] info cannot be obtained.
  Future<PrintersList> listPrinters() async {
    final availablePrinters =
        await _requestsService.listPrinters().onError((e, s) {
      if (e is RequestProcessorError) {
        throw ExportServiceException(e.error, e.stackTrace);
      } else {
        throw ExportServiceException(e.toString(), s.toString());
      }
    });

    final lastUsedPrinter = await _settingsRepository.lastUsedPrinter;

    final preferred =
        availablePrinters.contains(lastUsedPrinter)
            ? await _settingsRepository.lastUsedPrinter
            : null;

    return PrintersList(
      preferred,
      availablePrinters,
    );
  }

  /// Prints [document] on [printerName]. If [noLists] is `true` than no work
  /// list will be attached
  /// Throws [ExportServiceException] if document can't be printed.
  Future<void> printDocument(
    Document document,
    String printerName,
    bool noLists,
  ) async {
    // Update last used printer
    await _settingsRepository.setLastUsedPrinter(printerName);

    // Print the document
    await _requestsService
        .printDocument(document, printerName, noLists)
        .onError((e, s) {
      if (e is RequestProcessorError) {
        throw ExportServiceException(e.error, e.stackTrace);
      } else {
        throw ExportServiceException(e.toString(), s.toString());
      }
    });
  }

  /// Exports the [document] onto the [format]. Asks for save path
  /// using [pathChooser].
  /// Returns a stream of exporting steps.
  /// Throws [ExportServiceException] if document cannot be exported.
  Stream<ExportState> exportDocument(
    Document document,
    ExportFormat format,
  ) async* {
    yield ExportState.pickingFile;

    final filePath = await _fileSelector.getFile(format, document);

    if (filePath == null) {
      yield ExportState.done;
      return;
    }

    yield ExportState.exporting;

    await _getExporter(format, document, filePath).onError((e, s) {
      if (e is RequestProcessorError) {
        throw ExportServiceException(e.error, e.stackTrace);
      } else {
        throw ExportServiceException(e.toString(), s.toString());
      }
    });

    yield ExportState.done;
  }

  Future<void> _getExporter(
    ExportFormat format,
    Document document,
    String filePath,
  ) {
    switch (format) {
      case ExportFormat.pdf:
        return _requestsService.exportToPdf(document, filePath);
      case ExportFormat.excel:
        return _requestsService.exportToXlsx(document, filePath);
      default:
        throw "Unsupported case!";
    }
  }

  /// Checks whether requests service available or not
  Future<bool> isAvailable() => _requestsService.isAvailable();
}
