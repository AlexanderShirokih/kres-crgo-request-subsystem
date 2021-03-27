part of 'importer_bloc.dart';

/// Base state for [ImporterBloc]
@sealed
abstract class ImporterState extends Equatable {
  const ImporterState._();
}

/// Default (idle) state
class ImporterInitialState extends ImporterState {
  const ImporterInitialState() : super._();

  @override
  List<Object> get props => [];
}

/// Error state showing that importer module is not available
class ImporterModuleMissingState extends ImporterState {
  const ImporterModuleMissingState() : super._();

  @override
  List<Object> get props => [];
}

/// State when data is loading
class ImporterLoadingState extends ImporterState {
  /// Importing file source path
  final String path;

  const ImporterLoadingState(this.path) : super._();

  @override
  List<Object> get props => [path];
}

/// Describes cases of document importing
enum ImportResult {
  done,
  documentEmpty,
  importCancelled,
}

/// State used when document loading has finished
class ImporterDoneState extends ImporterState {
  /// Imported document. May be `null` if importing was cancelled
  final Document? document;

  /// The document import result
  final ImportResult importResult;

  const ImporterDoneState({
    this.document,
    required this.importResult,
  }) : super._();

  @override
  List<Object?> get props => [document, importResult];
}

/// State indicating that some error happened
class ImportErrorState extends ImporterState {
  final String error;
  final StackTrace? stackTrace;

  const ImportErrorState(this.error, this.stackTrace) : super._();

  @override
  List<Object?> get props => [error, stackTrace];
}
