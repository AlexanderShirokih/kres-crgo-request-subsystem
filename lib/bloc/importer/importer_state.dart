part of 'importer_bloc.dart';

abstract class ImporterState extends Equatable {
  const ImporterState();
}

class ImporterInitialState extends ImporterState {
  @override
  List<Object> get props => [];
}

class ImportLoadingState extends ImporterState {
  final String path;

  const ImportLoadingState(this.path);

  @override
  List<Object> get props => [path];
}

class WorksheetReadyState extends ImporterState {
  const WorksheetReadyState();

  @override
  List<Object> get props => [];
}

class ImportErrorState extends ImporterState {
  final Object error;
  final StackTrace stackTrace;

  const ImportErrorState(this.error, this.stackTrace);

  @override
  List<Object> get props => [error, stackTrace];
}
