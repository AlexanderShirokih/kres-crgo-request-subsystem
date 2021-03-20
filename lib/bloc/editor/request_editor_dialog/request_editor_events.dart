part of 'request_editor_bloc.dart';

/// Base class for [RequestEditorBloc]
@sealed
abstract class RequestEditorEvent extends Equatable {
  const RequestEditorEvent._();
}

/// Event used internally to fetch request types from repository
class _FetchRequestTypesEvent extends RequestEditorEvent {
  const _FetchRequestTypesEvent() : super._();

  @override
  List<Object?> get props => [];
}

/// Triggers updating request entity with new values
class UpdateRequestFieldsEvent extends RequestEditorEvent {
  /// Request type
  final RequestType? requestType;

  /// Account owner name
  final String name;

  /// Additional info, such as comments to the request
  final String additionalInfo;

  /// Request address
  final String address;

  /// Counter info
  final String counterInfo;

  /// Account ID
  final String accountId;

  const UpdateRequestFieldsEvent({
    required this.requestType,
    required this.name,
    required this.additionalInfo,
    required this.address,
    required this.counterInfo,
    required this.accountId,
  }) : super._();

  @override
  List<Object?> get props => [
        requestType,
        name,
        additionalInfo,
        address,
        counterInfo,
        accountId,
      ];
}
