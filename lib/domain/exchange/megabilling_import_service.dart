import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/domain/models/document.dart';

import 'document_importer_service.dart';

/// Exception class used when request processor module is missing
class ImporterProcessorMissingException implements Exception {}

/// A class responsible for importing requests stored as mega-billing XLS
/// document
class MegaBillingImportService implements DocumentImporterService {
  final AbstractRequestProcessor _requestProcessor;

  MegaBillingImportService(this._requestProcessor);

  /// Imports document previously exported to XLS by Mega-billing app
  @override
  Future<Document?> importDocument(String filePath) async {
    final isExists = await _requestProcessor.isAvailable();
    if (!isExists) throw ImporterProcessorMissingException();

    return await _requestProcessor.importRequests(filePath);
  }
}
