part of 'importer_bloc.dart';

abstract class ImporterEvent extends Equatable {
  const ImporterEvent();
}

class InitialEvent extends ImporterEvent {
  const InitialEvent();

  @override
  List<Object> get props => [];
}

class ImportEvent extends ImporterEvent {
  final bool attachPath;

  const ImportEvent({
    this.attachPath = true,
  });

  @override
  List<Object> get props => [attachPath];
}

class ImportErrorEvent extends ImporterEvent {
  final Object error;
  final StackTrace? stackTrace;

  const ImportErrorEvent(this.error, this.stackTrace);

  @override
  List<Object?> get props => [error, stackTrace];
}
