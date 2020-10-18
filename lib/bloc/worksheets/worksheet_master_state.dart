part of 'worksheet_master_bloc.dart';

abstract class WorksheetMasterState extends Equatable {
  const WorksheetMasterState(this.currentDocument, this.currentDirectory);

  final Document currentDocument;
  final String currentDirectory;

  @override
  List<Object> get props => [currentDocument, currentDirectory];
}

class WorksheetMasterPopState extends WorksheetMasterState {
  const WorksheetMasterPopState(Document currentDocument,
      String currentDirectory)
      : super(currentDocument, currentDirectory);
}

class WorksheetMasterIdleState extends WorksheetMasterState {
  static int _updateCounter = 0;

  final int _updateId = ++_updateCounter;

  WorksheetMasterIdleState(Document currentDocument, String currentDirectory)
      : super(currentDocument, currentDirectory);

  @override
  List<Object> get props => [...super.props, _updateId];
}

class WorksheetMasterSavingState extends WorksheetMasterState {
  final bool saved;
  final ErrorWrapper error;

  const WorksheetMasterSavingState(Document currentDocument,
      String currentDirectory, {this.saved, this.error})
      : super(currentDocument, currentDirectory);

  @override
  List<Object> get props => [...super.props, saved, error];
}

enum WorksheetImporterType {
  requestsImporter,
  nativeImporter,
  countersImporter,
}

class WorksheetMasterShowImporterState extends WorksheetMasterState {
  final WorksheetImporterType importerType;

  const WorksheetMasterShowImporterState(Document currentDocument,
      String currentDirectory, this.importerType,)
      : super(currentDocument, currentDirectory);

  @override
  List<Object> get props =>
      [...super.props, importerType];
}
