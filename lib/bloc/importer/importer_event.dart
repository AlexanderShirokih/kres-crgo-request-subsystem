part of 'importer_bloc.dart';

abstract class ImporterEvent extends Equatable {
  const ImporterEvent();
}

/// Used to begin importing file at [filePath] into the document.
/// If [filePath] is not set file chooser will be opened
class ImportEvent extends ImporterEvent {
  final File? filePath;

  const ImportEvent({this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Used internally to signal an error
class _ImportErrorEvent extends ImporterEvent {
  final Object error;
  final StackTrace? stackTrace;

  const _ImportErrorEvent(this.error, this.stackTrace);

  @override
  List<Object?> get props => [error, stackTrace];
}
