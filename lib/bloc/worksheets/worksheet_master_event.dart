part of 'worksheet_master_bloc.dart';

abstract class WorksheetMasterEvent extends Equatable {
  const WorksheetMasterEvent();
}

class WorksheetMasterRefreshDocumentStateEvent extends WorksheetMasterEvent {
  @override
  List<Object> get props => [];
}

class WorksheetMasterSearchEvent extends WorksheetMasterEvent {
  final String searchText;

  WorksheetMasterSearchEvent([this.searchText]);

  @override
  List<Object> get props => [searchText];
}

class WorksheetShowNotificationEvent extends WorksheetMasterEvent {
  final String message;

  WorksheetShowNotificationEvent(this.message) : assert(message != null);

  @override
  List<Object> get props => [message];
}
