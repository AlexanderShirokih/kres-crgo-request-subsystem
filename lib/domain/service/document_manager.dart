import 'package:kres_requests2/domain/models/document.dart';
import 'package:rxdart/rxdart.dart';

/// Manages opened [Document] instances
class DocumentManager {
  final BehaviorSubject<List<Document>> _openedDocuments;
  final BehaviorSubject<int> _selectedIndex;

  /// Creates a new document manager with empty document
  DocumentManager()
      : _openedDocuments = BehaviorSubject.seeded([]),
        _selectedIndex = BehaviorSubject();

  /// Creates a new document manager for document instances.
  /// Throws an error if [documents] is empty
  DocumentManager.forDocuments(List<Document> documents)
      : _openedDocuments = BehaviorSubject.seeded(documents),
        _selectedIndex = BehaviorSubject.seeded(0) {
    if (documents.isEmpty) {
      throw "Documents list should not be empty!";
    }
  }

  /// Returns a stream of opened documents. Returned list is unmodifiable.
  Stream<List<Document>> get openedDocumentsStream =>
      _openedDocuments.stream.map((list) => List.unmodifiable(list));

  /// Returns a stream with currently selected document
  Stream<Document?> get selectedStream => _selectedIndex
      .map((index) => index == -1 ? null : _openedDocuments.requireValue[index])
      .distinct();

  /// Returns currently selected document or `null` if there is no opened documents
  Document? get selected {
    final opened = _openedDocuments.value;
    final selected = _selectedIndex.value;

    if (opened == null || selected == null) {
      return null;
    }

    return opened[selected];
  }

  /// Closes internal resources and all opened documents
  Future<void> dispose() async {
    for (final document in _openedDocuments.requireValue) {
      await document.close();
    }

    await _openedDocuments.close();
    await _selectedIndex.close();
  }

  /// Adds [document] to the opened document list
  void addDocument(Document document) {
    final opened = _openedDocuments.requireValue;
    if (opened.contains(document)) {
      // Document is already opened
      return;
    }

    _addDocument(document);
  }

  /// Marks the [document] as selected
  void markSelected(Document document) {
    final index = _openedDocuments.requireValue.indexOf(document);

    if (index == -1) {
      throw 'Given document is not in the document list';
    }

    _selectedIndex.add(index);
  }

  /// Creates an empty document and adds it to the opened document list.
  /// Returns an instance of the opened document.
  Future<Document> createNew() {
    final document = Document.empty();

    _addDocument(document);

    return Future.value(document);
  }

  /// Closes previously opened document instance and removes it from
  /// opened documents list.
  Future<void> close(Document document) async {
    final opened = _openedDocuments.requireValue;
    final index = opened.indexOf(document);

    if (index != -1) {
      await opened.removeAt(index).close();

      final current = _selectedIndex.requireValue;
      if (current >= index) {
        _selectedIndex.add(current - 1);
      }

      _openedDocuments.add(List.of(opened));
    }
  }

  // Adds document to the list and notifies the stream
  void _addDocument(Document document) {
    _openedDocuments.add(_openedDocuments.requireValue..add(document));

    if (!_selectedIndex.hasValue || _selectedIndex.requireValue == -1) {
      _selectedIndex.add(0);
    }
  }
}
