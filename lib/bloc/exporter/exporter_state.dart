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
  @override
  List<Object> get props => [];
}

class ExporterClosingState extends ExporterState {
  final bool isCompleted;

  const ExporterClosingState({
    @required this.isCompleted,
  }) : assert(isCompleted != null);

  @override
  List<Object> get props => [];
}
