import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/request_service.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:meta/meta.dart';

part 'requests_move_dialog_events.dart';

/// Data holder class
class RequestsMoveDialogData extends Equatable {
  /// Original source from which requests will be moved
  final MoveSource source;

  /// Requests move targets
  final Iterable<MoveTarget> targets;

  const RequestsMoveDialogData(this.source, this.targets);

  @override
  List<Object?> get props => [source, targets];
}

/// BLoC responsible for moving requests among worksheets
class RequestsMoveDialogBloc extends Bloc<RequestMoveEvent, BaseState> {
  final RequestService _service;
  final IModularNavigator _navigator;

  RequestsMoveDialogBloc(
    this._service,
    this._navigator,
  ) : super(const InitialState());

  @override
  Stream<BaseState> mapEventToState(RequestMoveEvent event) async* {
    final currentState = state;

    if (event is FetchDataEvent) {
      yield DataState<RequestsMoveDialogData>(
        RequestsMoveDialogData(
          event.source,
          _service.getTargetWorksheets(event.source.worksheet),
        ),
      );
    } else if (event is MoveRequestsEvent &&
        currentState is DataState<RequestsMoveDialogData>) {
      _service.moveRequests(
        source: currentState.data.source,
        targetDocument: event.targetDocument,
        targetWorksheet: event.targetWorksheet,
        removeFromSource: event.removeFromSource,
        requests: event.requests,
      );

      _navigator.pop(true);
    }
  }
}
