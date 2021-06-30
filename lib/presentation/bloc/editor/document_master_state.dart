part of 'document_master_bloc.dart';

/// Base state of worksheet master BLoC
@sealed
abstract class DocumentMasterState extends Equatable {
  const DocumentMasterState._();
}

/// State indicating that no opened documents in the editor
class NoOpenedDocumentsState extends DocumentMasterState {
  const NoOpenedDocumentsState() : super._();

  @override
  List<Object?> get props => [];
}

/// Describes document saving state
enum SaveState { blank, unsaved, saved, saving }

/// Data class that holds document with it's state
class DocumentInfo extends Equatable {
  final SaveState saveState;
  final String title;
  final Document document;

  const DocumentInfo(this.saveState, this.title, this.document);

  /// Creates a copy with customizable params
  DocumentInfo copyWith({
    SaveState? saveState,
    String? title,
    Document? document,
  }) =>
      DocumentInfo(
        saveState ?? this.saveState,
        title ?? this.title,
        document ?? this.document,
      );

  @override
  List<Object?> get props => [title, saveState, document];
}

/// State used to show opened documents
class ShowDocumentsState extends DocumentMasterState {
  /// Currently selected document
  final Document selected;

  /// All opened documents
  final List<DocumentInfo> all;

  ShowDocumentsState(this.selected, this.all) : super._();

  @override
  List<Object?> get props => [selected, all];

  /// Creates a copy of [ShowDocumentsState] with ability to change some
  /// parameters
  ShowDocumentsState copyWith({
    Document? selected,
    List<DocumentInfo>? all,
  }) =>
      ShowDocumentsState(
        selected ?? this.selected,
        all ?? this.all,
      );
}

enum DocumentErrorType {
  savingError,
}

/// Used when some error happened in the document
class DocumentErrorState extends DocumentMasterState {
  /// Problematic document
  final Document target;

  /// Describes error type
  final DocumentErrorType error;

  /// Error description
  final String description;

  /// Error stack trace
  final StackTrace? stackTrace;

  const DocumentErrorState({
    required this.target,
    required this.error,
    required this.description,
    required this.stackTrace,
  }) : super._();

  @override
  List<Object?> get props => [target, error, description, stackTrace];
}
