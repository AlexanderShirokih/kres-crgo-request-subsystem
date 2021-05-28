part of 'request_editor_bloc.dart';

/// Base class for [RequestEditorBloc]
@sealed
abstract class RequestEditorEvent extends Equatable {
  const RequestEditorEvent._();
}

/// Sets request for editing
class SetRequestEvent extends RequestEditorEvent {
  /// Request to be edited. `null` if new request should be created
  final RequestEntity? request;

  /// Target document
  final Document document;

  /// Target worksheet
  final Worksheet worksheet;

  const SetRequestEvent({
    required this.document,
    required this.worksheet,
    required this.request,
  }) : super._();

  @override
  List<Object?> get props => [
        request,
        worksheet,
        document,
      ];
}

/// Used to commit changes with the request
class SaveRequestEvent extends RequestEditorEvent {
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
  final String counterType;

  /// Phone number
  final String phone;

  /// Counter number
  final String counterNumber;

  /// Check year
  final String checkYear;

  /// Transformation station number
  final String tp;

  /// Connection line number
  final String line;

  /// Endpoint pillar number
  final String pillar;

  /// Check quarter
  final int? checkQuarter;

  const SaveRequestEvent({
    required this.requestType,
    required this.name,
    required this.phone,
    required this.tp,
    required this.line,
    required this.pillar,
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
        tp,
        line,
        name,
        phone,
        pillar,
        address,
        checkYear,
        accountId,
        counterType,
        requestType,
        checkQuarter,
        counterNumber,
        additionalInfo,
      ];
}
