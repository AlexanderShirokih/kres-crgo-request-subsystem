import 'package:kres_requests2/domain/editor/document_filter.dart';
import 'package:kres_requests2/domain/models.dart';

/// Service for handling actions on document
class DocumentService {
  final Document document;
  final DocumentFilter documentFilter;

  DocumentService(
    this.document,
    this.documentFilter,
  );

  /// Adds an empty worksheet to the document
  void addEmptyWorksheet() {
    document.worksheets.add(activate: true);
  }

  /// Removes [target] worksheet from the document
  void removeWorksheet(Worksheet target) {
    document.worksheets.remove(target);
  }

  /// Makes the [target] worksheet active on the document
  void makeActive(Worksheet target) {
    document.worksheets.makeActive(target);
  }

  /// Sets the current document search text filter.
  /// When [searchText] is empty filter will be disabled
  void setSearchFilter(String searchText) {
    documentFilter.setSearchText(searchText);
  }
}
