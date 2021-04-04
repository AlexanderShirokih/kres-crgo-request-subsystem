part of 'requests_move_dialog_bloc.dart';

/// Defines events for [RequestsMoveDialogBloc]
@sealed
abstract class RequestMoveEvent extends Equatable {
  const RequestMoveEvent._();
}

/// Triggers moving requests
class MoveRequestsEvent extends RequestMoveEvent {
  /// Target requests to be moved or copied
  final List<RequestEntity> requests;

  /// If `true` then moving requests will be removed from the source worksheet
  final bool removeFromSource;

  /// Target worksheet. If `null` new worksheet will be created
  final Worksheet? target;

  const MoveRequestsEvent({
    this.target,
    required this.requests,
    required this.removeFromSource,
  }) : super._();

  @override
  List<Object?> get props => [requests, removeFromSource, target];
}
