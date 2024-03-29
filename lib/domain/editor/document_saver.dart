import 'dart:io';

import 'package:kres_requests2/domain/models.dart';

/// Stores current document state to external storage
abstract class DocumentSaver {
  /// Encodes document to external format and stores it to the some storage
  Future<void> store(Document document, [File? savePath]);

  /// Computes unique digest for [document]
  Future<String> digest(Document document);
}
