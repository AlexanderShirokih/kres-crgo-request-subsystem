part of 'document_master_bloc.dart';

/// Base state of worksheet master BLoC
@sealed
abstract class DocumentMasterState extends Equatable {
  const DocumentMasterState._();

  int get pageCount =>
      this is ShowDocumentsState ? (this as ShowDocumentsState).all.length : 0;

  int get pageIndex {
    if (this is ShowDocumentsState) {
      final state = this as ShowDocumentsState;
      return state.all.indexWhere((info) => info.document == state.selected);
    } else {
      return 0;
    }
  }
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
  final Document document;

  const DocumentInfo(this.saveState, this.document);

  /// Returns current document save path as a title.
  /// If document if not saved yet, it will be `null`
  String? get title => document.currentSavePath?.path;

  /// Creates a copy with customizable params
  DocumentInfo copyWith({
    SaveState? saveState,
    String? title,
    Document? document,
  }) =>
      DocumentInfo(
        saveState ?? this.saveState,
        document ?? this.document,
      );

  @override
  List<Object?> get props => [saveState, document];
}

/// State used to show opened documents
class ShowDocumentsState extends DocumentMasterState {
  /// Currently selected document
  final Document selected;

  /// All opened documents
  final List<DocumentInfo> all;

  const ShowDocumentsState(this.selected, this.all) : super._();

  @override
  List<Object?> get props => [selected, all];

  get selectedIndex => null;

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
