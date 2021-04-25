part of 'worksheet_master_bloc.dart';

/// Base state of worksheet master BLoC
@sealed
abstract class WorksheetMasterState extends Equatable {
  const WorksheetMasterState._(this.currentDocument);

  /// Currently opened document
  final Document currentDocument;

  /// Document title. Contains current document save path
  Stream<String> get documentTitle => currentDocument.savePath.map((savePath) {
        if (savePath == null) return "Несохранённый документ [sP=null]";
        return savePath.path;
      });

  @override
  List<Object?> get props => [currentDocument];
}

/// A state that signals that the current document should be closed
class WorksheetMasterPopState extends WorksheetMasterState {
  const WorksheetMasterPopState(Document currentDocument)
      : super._(currentDocument);
}

/// Default worksheet master state that shows document in a normal mode
class WorksheetMasterIdleState extends WorksheetMasterState {
  static int _updateCounter = 0;

  final int _updateId = ++_updateCounter;

  WorksheetMasterIdleState(Document currentDocument) : super._(currentDocument);

  @override
  List<Object?> get props => [_updateId, ...super.props];
}

/// A state used when document is saving
class WorksheetMasterSavingState extends WorksheetMasterState {
  /// `true` if saving was completed with any result
  final bool completed;

  /// Contains error if [completed] == `true` and saving was unsuccessful
  final String? error;
  final StackTrace? stackTrace;

  const WorksheetMasterSavingState(
    Document currentDocument, {
    this.completed = false,
    this.error,
    this.stackTrace,
  }) : super._(currentDocument);

  @override
  List<Object?> get props => [
        ...super.props,
        completed,
        error,
        stackTrace,
      ];
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
    this.importerType,
  ) : super._(currentDocument);

  @override
  List<Object?> get props => [...super.props, importerType];
}
