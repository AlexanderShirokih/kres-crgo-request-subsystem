part of 'exporter_bloc.dart';

/// Base event class for [ExporterBloc]
abstract class ExporterEvent extends Equatable {
  const ExporterEvent();
}

/// Used internally when some error happened on exporting time
class _ExporterErrorEvent extends ExporterEvent {
  final String error;
  final StackTrace stackTrace;

  const _ExporterErrorEvent(this.error, this.stackTrace);

  @override
  List<Object> get props => [error, this.stackTrace];
}

/// Used internally to open save dialog
class _ExporterShowSaveDialogEvent extends ExporterEvent {
  @override
  List<Object> get props => [];
}

/// Common class for starting events
abstract class _ExporterInitialEvent extends ExporterEvent {
  const _ExporterInitialEvent() : super();
}

/// Used to fetch printers list
class ExporterShowPrintersListEvent extends _ExporterInitialEvent {
  @override
  List<Object> get props => [];
}

/// Signals to print target document on [printerName]
class ExporterPrintDocumentEvent extends _ExporterInitialEvent {
  /// Chosen printer
  final String printerName;

  /// Skip printing working lists
  final bool noLists;

  const ExporterPrintDocumentEvent(this.printerName, this.noLists);

  @override
  List<Object> get props => [printerName, noLists];
}
