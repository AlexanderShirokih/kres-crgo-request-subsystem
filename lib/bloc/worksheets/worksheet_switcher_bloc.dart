import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/bloc/worksheets/worksheet_master_bloc.dart';
import 'package:kres_requests2/domain/document_service.dart';
import 'package:kres_requests2/models/request_set.dart';

part 'worksheet_switcher_event.dart';

part 'worksheet_switcher_state.dart';

/// BLoC for switching between worksheets
class WorksheetSwitcherBloc
    extends Bloc<WorksheetSwitcherEvent, WorksheetSwitcherState> {
  final DocumentService _documentService;
  final WorksheetMasterBloc _masterBloc;

  WorksheetSwitcherBloc(this._documentService, this._masterBloc)
      : assert(_documentService != null),
        assert(_masterBloc != null),
        super(WorksheetSwitcherInitial()) {
    add(WorksheetSwitcherFetchEvent());
  }

  @override
  Stream<WorksheetSwitcherState> mapEventToState(
      WorksheetSwitcherEvent event) async* {
    if (event is WorksheetSwitcherFetchEvent) {
      yield _showWorksheets();
    } else if (event is WorksheetSwitcherSetActiveEvent) {
      _documentService.setActive(event.active);
      _masterBloc.add(WorksheetMasterRefreshDocumentStateEvent());
      yield _showWorksheets();
    } else if (event is WorksheetSwitcherRenameEvent) {
      yield* _handleResult(
          () => _documentService.getEditor(event.target).setName(event.newName),
          'переименовать');
    } else if (event is WorksheetSwitcherRemoveEvent) {
      yield* _handleResult(
          () => _documentService.removeWorksheet(event.target), 'удалить');
    } else if (event is WorksheetSwitcherAddNewEvent) {
      yield* _handleResult(
          () => _documentService.addNewWorksheet(), 'добавить');
    }
  }

  WorksheetSwitcherState _showWorksheets() => WorksheetSwitcherShowWorksheets(
        _documentService.getWorksheets(),
        _documentService.getActive(),
      );

  Stream<WorksheetSwitcherState> _handleResult(
      Future<bool> Function() action, String failVerb) async* {
    final isOk = await action();
    if (isOk) {
      yield _showWorksheets();
    } else {
      _masterBloc.add(
          WorksheetShowNotificationEvent('Не удалось $failVerb страницу!'));
    }
  }
}
