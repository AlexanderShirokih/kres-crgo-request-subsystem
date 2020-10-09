part of 'exporter_bloc.dart';

abstract class ExporterState extends Equatable {
  const ExporterState();
}

class ExporterInitial extends ExporterState {
  @override
  List<Object> get props => [];
}

class ExporterMissingState extends ExporterState {
  @override
  List<Object> get props => [];
}

class ExporterErrorState extends ExporterState {
  final ExporterProcessException exception;

  const ExporterErrorState(this.exception);

  @override
  List<Object> get props => [exception];
}

class ExporterClosingState extends ExporterState {
  final bool isCompleted;

  const ExporterClosingState({
    @required this.isCompleted,
  }) : assert(isCompleted != null);

  @override
  List<Object> get props => [];
}
