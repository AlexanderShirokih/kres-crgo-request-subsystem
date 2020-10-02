part of 'startup_bloc.dart';

abstract class StartupEvent extends Equatable {
  const StartupEvent();
}

class StartupInitialEvent extends StartupEvent {
  const StartupInitialEvent();

  @override
  List<Object> get props => [];
}

class StartupImportEvent extends StartupEvent {
  final String path;

  const StartupImportEvent(this.path);

  @override
  List<Object> get props => [path];
}
