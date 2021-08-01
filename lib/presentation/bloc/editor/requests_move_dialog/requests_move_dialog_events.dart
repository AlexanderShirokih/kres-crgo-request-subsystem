part of 'requests_move_dialog_bloc.dart';

/// Defines events for [RequestsMoveDialogBloc]
@sealed
abstract class RequestMoveEvent extends Equatable {
  const RequestMoveEvent._();
}

/// Used to trigger initial data fetching
class FetchDataEvent extends RequestMoveEvent {
  /// Current source worksheet and document from which request will copying
  final MoveSource source;

  const FetchDataEvent(this.source) : super._();

  @override
  List<Object?> get props => [source];
}

/// Triggers moving requests
class MoveRequestsEvent extends RequestMoveEvent {
  /// Target requests to be moved or copied
  final List<Request> requests;

  /// If `true` then moving requests will be removed from the source worksheet
  final bool removeFromSource;

  /// The document owning [targetWorksheet]
  final Document targetDocument;

  /// Request move target. If worksheet is `null` new worksheet will be created.
  final Worksheet? targetWorksheet;

  const MoveRequestsEvent({
    required this.targetDocument,
    required this.targetWorksheet,
    required this.requests,
    required this.removeFromSource,
  }) : super._();

  @override
  List<Object?> get props => [
        targetDocument,
        targetWorksheet,
        requests,
        removeFromSource,
      ];
}
