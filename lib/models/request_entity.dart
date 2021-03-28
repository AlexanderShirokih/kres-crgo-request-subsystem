import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/models/connection_point.dart';
import 'package:kres_requests2/models/counter_info.dart';

/// Describes information about work request
class RequestEntity extends Equatable {
  /// An account number (up to 6 digit)
  final int? accountId;

  /// Requester name
  final String name;

  /// Requester address
  final String address;

  /// A request type
  final RequestType? requestType;

  /// Phone number
  final String? phoneNumber;

  /// Additional info to request (comments)
  final String? additionalInfo;

  /// Connection point
  final ConnectionPoint? connectionPoint;

  /// Electrical counter info
  final CounterInfo? counter;

  /// Request reason
  final String? reason;

  const RequestEntity({
    required this.name,
    required this.address,
    required this.counter,
    required this.additionalInfo,
    this.phoneNumber,
    this.accountId,
    this.connectionPoint,
    this.requestType,
    this.reason,
  });

  /// `true` if all fields are empty
  bool get isNew => this == RequestEntity.empty();

  /// Converts account ID to string
  String get printableAccountId =>
      accountId?.toString().padLeft(6, '0') ?? "--";

  /// Creates [RequestEntity] instance from JSON
  /// TODO: Legacy!
  factory RequestEntity.fromJson(Map<String, dynamic> data) => RequestEntity(
        accountId: data['accountId'],
        name: data['name'],
        address: data['address'],
        requestType: RequestType(
          shortName: data['reqType'],
          fullName: data['fullReqType'],
        ),
        additionalInfo: data['additionalInfo'],
        counter: data['counterInfo'],
        reason: data['reason'],
      );

  /// Converts [RequestEntity] to JSON representation
  /// TODO: Legacy!
  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'name': name,
        'address': address,
        'reqType': requestType?.shortName,
        'fullReqType': requestType?.fullName,
        'additionalInfo': additionalInfo,
        'counterInfo': counter?.fullInfo,
        'reason': reason,
      };

  factory RequestEntity.empty() => const RequestEntity(
        name: "",
        address: "",
        counter: null,
        additionalInfo: "",
        connectionPoint: null,
        accountId: null,
      );

  /// Creates a copy of object with specifying parameters
  RequestEntity copy({
    int? accountId,
    String? name,
    String? reason,
    String? address,
    CounterInfo? counter,
    ConnectionPoint? connectionPoint,
    String? phoneNumber,
    String? additionalInfo,
    RequestType? requestType,
  }) =>
      RequestEntity(
        accountId: accountId ?? this.accountId,
        name: name ?? this.name,
        address: address ?? this.address,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        requestType: requestType ?? this.requestType,
        additionalInfo: additionalInfo ?? this.additionalInfo,
        connectionPoint: connectionPoint ?? this.connectionPoint,
        counter: counter ?? this.counter,
        reason: reason ?? this.reason,
      );

  @override
  List<Object?> get props => [
        accountId,
        name,
        address,
        requestType,
        additionalInfo,
        connectionPoint,
        phoneNumber,
        counter,
        reason,
      ];
}
