part of 'importer_bloc.dart';

abstract class ImporterEvent extends Equatable {
  const ImporterEvent();
}

/// Used to begin importing file at [filePath] into the document.
/// If [filePath] is not set file chooser will be opened
class ImportEvent extends ImporterEvent {
  final File? filePath;

  /// If target is not `null`, resulting document will be merged with [mergeTarget].
  /// Otherwise new document will be created
  final Document? mergeTarget;

  const ImportEvent({this.filePath, this.mergeTarget});

  @override
  List<Object?> get props => [filePath];
}
