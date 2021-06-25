import 'package:kres_requests2/domain/request_processor.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';

import 'document_import_service.dart';

/// A class responsible for importing requests stored as mega-billing XLS
/// document
class MegaBillingImportService implements DocumentImporter {
  final AbstractRequestProcessor _requestProcessor;

  MegaBillingImportService(this._requestProcessor);

  /// Imports document previously exported to XLS by Mega-billing app
  @override
  Future<bool> importDocument(String filePath, DocumentManager manager) async {
    final isExists = await _requestProcessor.isAvailable();
    if (!isExists) throw ImporterModuleMissingException();

    final result = await _requestProcessor.importRequests(filePath);
    manager.addDocument(result);

    return true;
  }
}
