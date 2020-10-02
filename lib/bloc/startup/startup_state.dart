part of 'startup_bloc.dart';

abstract class StartupState extends Equatable {
  const StartupState();
}

class StartupInitial extends StartupState {
  @override
  List<Object> get props => [];
}

class StartupLoadingState extends StartupState {
  final String path;

  const StartupLoadingState(this.path);

  @override
  List<Object> get props => [path];
}

class StartupShowDocumentState extends StartupState {
  final Document document;

  const StartupShowDocumentState(this.document);

  @override
  List<Object> get props => [document];
}

class StartupErrorState extends StartupState {
  final Object error;
  final StackTrace stackTrace;

  const StartupErrorState(this.error, this.stackTrace);

  @override
  List<Object> get props => [error, stackTrace];
}
