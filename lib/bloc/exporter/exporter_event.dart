part of 'exporter_bloc.dart';

abstract class ExporterEvent extends Equatable {
  const ExporterEvent();
}

abstract class ExporterInitialEvent extends ExporterEvent {
  const ExporterInitialEvent();
}

class ExporterErrorEvent extends ExporterEvent {
  final RequestsProcessException exception;

  const ExporterErrorEvent(this.exception);

  @override
  List<Object> get props => [exception];
}

class ExporterShowSaveDialogEvent extends ExporterInitialEvent {
  @override
  List<Object> get props => [];
}

class ExporterShowPrintersListEvent extends ExporterInitialEvent {
  @override
  List<Object> get props => [];
}

class ExporterPrintDocumentEvent extends ExporterEvent {
  final String printerName;
  final bool noLists;

  const ExporterPrintDocumentEvent(this.printerName, this.noLists)
      : assert(printerName != null),
        assert(noLists != null);

  @override
  List<Object> get props => [printerName, noLists];
}
