part of 'worksheet_master_bloc.dart';

abstract class WorksheetMasterState extends Equatable {
  const WorksheetMasterState(this.documentRepository);

  final DocumentRepository documentRepository;

  @override
  List<Object> get props => [documentRepository];
}

class WorksheetMasterPopState extends WorksheetMasterState {
  const WorksheetMasterPopState(DocumentRepository documentRepository)
      : super(documentRepository);
}

class WorksheetMasterIdleState extends WorksheetMasterState {
  static int _updateCounter = 0;

  final int _updateId = ++_updateCounter;

  WorksheetMasterIdleState(DocumentRepository documentRepository)
      : super(documentRepository);

  @override
  List<Object> get props => [...super.props, _updateId];
}

class WorksheetMasterSavingState extends WorksheetMasterState {
  final bool completed;
  final ErrorWrapper error;

  const WorksheetMasterSavingState(DocumentRepository documentRepository,
      {this.completed, this.error})
      : super(documentRepository);

  @override
  List<Object> get props => [...super.props, completed, error];
}

enum WorksheetImporterType {
  requestsImporter,
  nativeImporter,
  countersImporter,
}

class WorksheetMasterShowImporterState extends WorksheetMasterState {
  final WorksheetImporterType importerType;

  const WorksheetMasterShowImporterState(
    DocumentRepository documentRepository,
    this.importerType,
  ) : super(documentRepository);

  @override
  List<Object> get props => [...super.props, importerType];
}

class WorksheetMasterSearchingState extends WorksheetMasterState {
  final String searchText;

  const WorksheetMasterSearchingState(
    DocumentRepository documentRepository, {
    @required this.searchText,
  })  :
        super(documentRepository);

  @override
  List<Object> get props => super.props + [searchText];
}
