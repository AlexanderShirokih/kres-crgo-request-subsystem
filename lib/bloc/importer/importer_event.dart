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

  const ImportEvent({
    @required this.path,
    @required this.targetDocument,
  })  : assert(path != null),
        assert(targetDocument != null);

  @override
  List<Object> get props => [path];
}
