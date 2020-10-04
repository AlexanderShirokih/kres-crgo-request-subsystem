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
  final String path;
  final Document targetDocument;
  final bool attachPath;

  const ImportEvent({
    @required this.path,
    @required this.targetDocument,
    this.attachPath = true,
  })  : assert(path != null),
        assert(attachPath != null);

  @override
  List<Object> get props => [path];
}
