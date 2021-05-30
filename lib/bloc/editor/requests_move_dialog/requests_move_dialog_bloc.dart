import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/request_editor_service.dart';
import 'package:kres_requests2/screens/bloc.dart';
import 'package:meta/meta.dart';

part 'requests_move_dialog_events.dart';

/// Data holder class
class RequestsMoveDialogData extends Equatable {
  final Worksheet source;
  final Iterable<Worksheet> targets;

  RequestsMoveDialogData(this.source, this.targets);

  @override
  List<Object?> get props => [source, targets];
}

/// BLoC responsible for moving requests among worksheets
class RequestsMoveDialogBloc extends Bloc<RequestMoveEvent, BaseState> {
  final RequestEditorService _service;

  RequestsMoveDialogBloc(this._service) : super(InitialState());

  @override
  Stream<BaseState> mapEventToState(RequestMoveEvent event) async* {
    final currentState = state;

    if (event is FetchDataEvent) {
      yield DataState<RequestsMoveDialogData>(
        RequestsMoveDialogData(
          event.sourceWorksheet,
          _service.getTargetWorksheets(event.sourceWorksheet),
        ),
      );
    } else if (event is MoveRequestsEvent &&
        currentState is DataState<RequestsMoveDialogData>) {
      _service.moveRequests(
        source: currentState.data.source,
        target: event.target,
        removeFromSource: event.removeFromSource,
        requests: event.requests,
      );

      yield CompletedState();
    }
  }
}
