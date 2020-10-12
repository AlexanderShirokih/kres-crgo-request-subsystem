part of 'exporter_bloc.dart';

abstract class ExporterState extends Equatable {
  const ExporterState();
}

class ExporterIdle extends ExporterState {
  final String message;

  const ExporterIdle({this.message});

  @override
  List<Object> get props => [message];
}

class ExporterMissingState extends ExporterState {
  @override
  List<Object> get props => [];
}

class ExporterErrorState extends ExporterState {
  final ErrorWrapper error;

  const ExporterErrorState(this.error);

  @override
  List<Object> get props => [error];
}

class ExporterClosingState extends ExporterState {
  final bool isCompleted;

  const ExporterClosingState({
    @required this.isCompleted,
  }) : assert(isCompleted != null);

  @override
  List<Object> get props => [];
}

class ExporterListPrintersState extends ExporterState {
  final String preferredPrinter;
  final List<String> availablePrinters;

  const ExporterListPrintersState(
      this.preferredPrinter, this.availablePrinters);

  @override
  List<Object> get props => [
        preferredPrinter,
        availablePrinters,
      ];
}
