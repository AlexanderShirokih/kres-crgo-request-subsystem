import 'package:kres_requests2/domain/models/document.dart';

/// Service interface used to import document from external formats
abstract class DocumentImporterService {
  const DocumentImporterService();

  /// Runs parser program and returns document containing parsing result
  Future<Document?> importDocument(String filePath);
}
