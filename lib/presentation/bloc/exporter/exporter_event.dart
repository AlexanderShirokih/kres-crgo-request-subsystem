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
  List<Object> get props => [error, stackTrace];
}

/// Common class for starting events
abstract class _ExporterStartEvent extends ExporterEvent {
  const _ExporterStartEvent() : super();
}

/// Used to open save dialog and export document in appropriate format
class ExportEvent extends _ExporterStartEvent {
  /// Target export format
  final ExportFormat exportFormat;

  /// Document to be exported
  final Document document;

  const ExportEvent(this.exportFormat, this.document);

  @override
  List<Object> get props => [exportFormat, document];
}

/// Used to fetch printers list
class ShowPrintersListEvent extends _ExporterStartEvent {
  @override
  List<Object> get props => [];
}

/// Signals to print target document on [printerName]
class PrintDocumentEvent extends _ExporterStartEvent {
  /// Document to be printed
  final Document document;

  /// Chosen printer
  final String printerName;

  /// Skip printing working lists
  final bool noLists;

  const PrintDocumentEvent(this.document, this.printerName, this.noLists);

  @override
  List<Object> get props => [document, printerName, noLists];
}
