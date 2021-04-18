import 'package:kres_requests2/domain/models/document.dart';

/// Factory for loading [Document] instances from external sources
abstract class DocumentFactory {
  /// Creates new [Document]
  Document createDocument();
}
