import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models/request_type.dart';

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

  /// Additional info, such as additionalInfo, phone number, connection point
  final String? additionalInfo;

  /// Electrical counter info
  final String? counterInfo;

  /// Request reason
  final String? reason;

  const RequestEntity({
    required this.name,
    required this.address,
    required this.counterInfo,
    required this.additionalInfo,
    this.accountId,
    this.requestType,
    this.reason,
  });

  /// `true` all fields are empty
  bool get isNew => this == RequestEntity.empty();

  /// Converts account ID to string
  String get printableAccountId =>
      accountId?.toString().padLeft(6, '0') ?? "--";

  /// Creates [RequestEntity] instance from JSON
  factory RequestEntity.fromJson(Map<String, dynamic> data) => RequestEntity(
        accountId: data['accountId'],
        name: data['name'],
        address: data['address'],
        requestType: RequestType(
          shortName: data['reqType'],
          fullName: data['fullReqType'],
        ),
        additionalInfo: data['additionalInfo'],
        counterInfo: data['counterInfo'],
        reason: data['reason'],
      );

  /// Converts [RequestEntity] to JSON representation
  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'name': name,
        'address': address,
        'reqType': requestType?.shortName,
        'fullReqType': requestType?.fullName,
        'additionalInfo': additionalInfo,
        'counterInfo': counterInfo,
        'reason': reason,
      };

  factory RequestEntity.empty() => const RequestEntity(
        name: "",
        address: "",
        counterInfo: "",
        additionalInfo: "",
        accountId: null,
      );

  /// Creates a copy of object with specifying parameters
  RequestEntity copy({
    int? accountId,
    String? name,
    String? reason,
    String? address,
    String? counterInfo,
    String? additionalInfo,
    RequestType? requestType,
  }) =>
      RequestEntity(
        accountId: accountId ?? this.accountId,
        name: name ?? this.name,
        address: address ?? this.address,
        requestType: requestType ?? this.requestType,
        additionalInfo: additionalInfo ?? this.additionalInfo,
        counterInfo: counterInfo ?? this.counterInfo,
        reason: reason ?? this.reason,
      );

  @override
  List<Object?> get props => [
        accountId,
        name,
        address,
        requestType,
        additionalInfo,
        counterInfo,
        reason,
      ];
}
