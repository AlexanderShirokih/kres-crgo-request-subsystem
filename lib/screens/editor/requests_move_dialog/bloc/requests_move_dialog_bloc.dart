import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/request_entity.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/screens/bloc.dart';
import 'package:meta/meta.dart';

part 'requests_move_dialog_events.dart';

/// Signals to close the dialog
class ClosingState extends BaseState {
  const ClosingState();

  @override
  List<Object?> get props => [];
}

/// BLoC responsible for moving requests among worksheets
class RequestsMoveDialogBloc extends Bloc<RequestMoveEvent, BaseState> {
  final Document _document;
  final Worksheet _sourceWorksheet;

  RequestsMoveDialogBloc(
    this._document,
    this._sourceWorksheet,
  ) : super(
          DataState(
            _document.currentWorksheets.where(
              (worksheet) => worksheet != _sourceWorksheet,
            ),
          ),
        );

  @override
  Stream<BaseState> mapEventToState(RequestMoveEvent event) async* {
    if (event is MoveRequestsEvent) {
      final WorksheetEditor target;

      if (event.target == null) {
        target = _document.addEmptyWorksheet(name: _sourceWorksheet.name);
        _document.makeActive(target.current);
      } else {
        target = _document.edit(event.target!);
      }

      _moveRequests(
        targetWorksheetEditor: target,
        removeFromSource: event.removeFromSource,
        requests: event.requests,
      );

      yield ClosingState();
    }
  }

  void _moveRequests({
    required List<RequestEntity> requests,
    required WorksheetEditor targetWorksheetEditor,
    required bool removeFromSource,
  }) {
    targetWorksheetEditor.addAll(requests);

    if (removeFromSource) {
      _document.edit(_sourceWorksheet).removeRequests(requests);
    }
  }
}
