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

  /// Account ID
  final String accountId;

  /// Counter type
  final String? counterType;

  /// Counter number
  final String? counterNumber;

  /// Check year
  final String? checkYear;

  /// Check quarter
  final int? checkQuarter;

  const UpdateRequestFieldsEvent({
    required this.requestType,
    required this.name,
    required this.additionalInfo,
    required this.address,
    required this.counterType,
    required this.counterNumber,
    required this.checkYear,
    required this.checkQuarter,
    required this.accountId,
  }) : super._();

  @override
  List<Object?> get props => [
        requestType,
        name,
        additionalInfo,
        address,
        counterType,
        counterNumber,
        checkYear,
        checkQuarter,
        accountId,
      ];
}
