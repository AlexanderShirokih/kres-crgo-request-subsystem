part of 'exporter_bloc.dart';

abstract class ExporterEvent extends Equatable {
  const ExporterEvent();
}

class ExporterShowSaveDialogEvent extends ExporterEvent {
  @override
  List<Object> get props => [];
}
