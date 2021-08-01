import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/request_processor.dart';

import 'document_import_service.dart';

/// A class responsible for importing requests stored as mega-billing XLS
/// document
class MegaBillingImportService extends DocumentImporter {
  final AbstractRequestProcessor _requestProcessor;

  MegaBillingImportService(this._requestProcessor);

  /// Imports document previously exported to XLS by Mega-billing app
  @override
  Future<Document?> doImport(String filePath) async {
    final isExists = await _requestProcessor.isAvailable();
    if (!isExists) throw ImporterModuleMissingException();

    return await _requestProcessor.importRequests(filePath);
  }
}
