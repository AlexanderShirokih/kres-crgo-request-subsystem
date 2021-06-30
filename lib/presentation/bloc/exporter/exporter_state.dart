part of 'exporter_bloc.dart';

/// Base state class for [ExporterBloc]
abstract class ExporterState extends Equatable {
  const ExporterState();
}

/// Used when exporter does some action or does nothing
class ExporterIdle extends ExporterState {
  /// Message to be shown
  final String? message;

  const ExporterIdle({this.message});

  @override
  List<Object?> get props => [message];
}

/// Signals that exporter module is missing
class ExporterMissingState extends ExporterState {
  @override
  List<Object> get props => [];
}

/// Signals that an error happens on exporting time
class ExporterErrorState extends ExporterState {
  final String error;
  final String stackTrace;

  const ExporterErrorState(this.error, this.stackTrace);

  @override
  List<Object> get props => [error, stackTrace];
}

/// Yielded when exporting has completed with any result to close the dialog.
class ExporterClosingState extends ExporterState {
  /// If `true` then exporting was completed with result
  final bool isCompleted;

  const ExporterClosingState({
    required this.isCompleted,
  });

  @override
  List<Object> get props => [isCompleted];
}

/// Prints a list of all available printers
class ExporterListPrintersState extends ExporterState {
  /// Last used (preferred) printer name
  final String? preferredPrinter;

  /// Names of all available printers
  final List<String> availablePrinters;

  const ExporterListPrintersState(
    this.preferredPrinter,
    this.availablePrinters,
  );

  @override
  List<Object?> get props => [
        preferredPrinter,
        availablePrinters,
      ];
}
