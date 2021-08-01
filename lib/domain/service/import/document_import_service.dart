import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:meta/meta.dart';

enum ImportType {
  /// A set of mega-billing requests stored in XLS format
  excelRequests,

  /// A list of counters stored in XLSX format
  excelCounters,

  /// Native file format
  native,
}

/// Exception class that signals an error in document importing
class ImporterException implements Exception {
  final String cause;
  final StackTrace stackTrace;

  ImporterException(this.cause, this.stackTrace);
}

/// Special kind of [ImporterException] that thrown when importer module is
/// missing
class ImporterModuleMissingException extends ImporterException {
  ImporterModuleMissingException()
      : super("Importer module is missing", StackTrace.current);
}

/// Service interface used to import document from external formats
abstract class DocumentImporter {
  const DocumentImporter();

  /// Runs parser program to import the document
  /// Throws [ImporterModuleMissingException] if importer module is not available
  /// Throws [ImporterException] on any other errors
  /// Returns `false` if document import is cancelled.
  Future<bool> importDocument(
    String filePath,
    DocumentManager manager, [
    Document? target,
  ]) async {
    final newDocument = await doImport(filePath);

    if (newDocument == null) {
      return false;
    }

    if (target != null) {
      // Merge with existing document
      target.worksheets.addWorksheets(newDocument.worksheets.list);
      await newDocument.close();
    } else {
      // Register new document in the document manager
      manager.addDocument(newDocument);
    }
    return true;
  }

  @protected
  Future<Document?> doImport(String filePath);
}
