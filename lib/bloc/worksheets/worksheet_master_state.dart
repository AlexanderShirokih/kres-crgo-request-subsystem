part of 'worksheet_master_bloc.dart';

/// Base state of worksheet master BLoC
@sealed
abstract class WorksheetMasterState extends Equatable {
  const WorksheetMasterState._(this.currentDocument, this.currentDirectory);

  /// Currently opened document
  final Document currentDocument;

  /// Current working directory where document opened
  final String currentDirectory;

  /// Document title. Contains current document save path
  String get documentTitle => currentDocument.savePath == null
      ? "Несохранённый документ"
      : currentDocument.savePath?.path ?? 'error';

  @override
  List<Object?> get props => [currentDocument, currentDirectory];
}

/// A state that signals that the current document should be closed
class WorksheetMasterPopState extends WorksheetMasterState {
  const WorksheetMasterPopState(
      Document currentDocument, String currentDirectory)
      : super._(currentDocument, currentDirectory);
}

/// Default worksheet master state that shows document in a normal mode
class WorksheetMasterIdleState extends WorksheetMasterState {
  static int _updateCounter = 0;

  final int _updateId = ++_updateCounter;

  WorksheetMasterIdleState(Document currentDocument, String currentDirectory)
      : super._(currentDocument, currentDirectory);

  @override
  List<Object?> get props => [...super.props, _updateId];
}

/// A state used when document is saving
class WorksheetMasterSavingState extends WorksheetMasterState {
  /// `true` if saving was completed with any result
  final bool completed;

  /// Contains error if [completed] == `true` and saving was unsuccessful
  final ErrorWrapper? error;

  const WorksheetMasterSavingState(
    Document currentDocument,
    String currentDirectory, {
    this.completed = false,
    this.error,
  }) : super._(currentDocument, currentDirectory);

  @override
  List<Object?> get props => [...super.props, completed, error];
}

/// Describes document importer types
enum WorksheetImporterType {
  /// Imports page from request list prepared in the specified format
  requestsImporter,

  /// Opens previously document saved in the native format to separate pages
  nativeImporter,

  /// Imports a list of counters in a separate page
  countersImporter,
}

/// State that triggers opening importer wizard
class WorksheetMasterShowImporterState extends WorksheetMasterState {
  /// Importer type
  final WorksheetImporterType importerType;

  const WorksheetMasterShowImporterState(
    Document currentDocument,
    String currentDirectory,
    this.importerType,
  ) : super._(currentDocument, currentDirectory);

  @override
  List<Object?> get props => [...super.props, importerType];
}

/// State used when searching/filtering mode is active
class WorksheetMasterSearchingState extends WorksheetMasterState {
  /// Current searching request
  final WorksheetMasterSearchEvent sourceEvent;

  /// List of requests that passes the search filter groped by worksheet
  final Map<Worksheet, List<RequestEntity>> filteredItems;

  const WorksheetMasterSearchingState(
    Document currentDocument,
    String currentDirectory, {
    required this.sourceEvent,
    required this.filteredItems,
  }) : super._(currentDocument, currentDirectory);

  @override
  List<Object?> get props => super.props + [filteredItems, sourceEvent];
}
