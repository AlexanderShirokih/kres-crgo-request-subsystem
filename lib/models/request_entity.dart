import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/models/connection_point.dart';
import 'package:kres_requests2/models/counter_info.dart';

/// Describes information about work request
abstract class RequestEntity extends Equatable {
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
  bool get isEmpty {
    return name.isEmpty &&
        address.isEmpty &&
        (additionalInfo?.isEmpty ?? true) &&
        (counter?.isEmpty ?? true) &&
        (connectionPoint?.isEmpty ?? true) &&
        accountId == null;
  }

  /// Converts account ID to string
  String get printableAccountId =>
      accountId?.toString().padLeft(6, '0') ?? "--";

  /// Creates [RequestEntity] instance from JSON
  /// TODO: Legacy!
  // factory RequestEntity.fromJson(Map<String, dynamic> data) => RequestEntity(
  //       accountId: data['accountId'],
  //       name: data['name'],
  //       address: data['address'],
  //       requestType: RequestType(
  //         shortName: data['reqType'],
  //         fullName: data['fullReqType'],
  //       ),
  //       additionalInfo: data['additionalInfo'],
  //       counter: data['counterInfo'],
  //       reason: data['reason'],
  //     );

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

  /// Creates a builder to create a deep copy of the object
  RequestEntityBuilder rebuild();

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

abstract class RequestEntityBuilder {
  /// An account number (up to 6 digit)
  int? accountId;

  /// Requester name
  String? name;

  /// Requester address
  String? address;

  /// A request type
  RequestType? requestType;

  /// Phone number
  String? phoneNumber;

  /// Additional info to request (comments)
  String? additionalInfo;

  /// Connection point
  ConnectionPoint? connectionPoint;

  /// Electrical counter info
  CounterInfo? counter;

  /// Request reason
  String? reason;

  RequestEntityBuilder.from(RequestEntity entity) {
    this
      ..address = entity.address
      ..accountId = entity.accountId
      ..additionalInfo = entity.additionalInfo
      ..connectionPoint = entity.connectionPoint
      ..counter = entity.counter
      ..name = entity.name
      ..phoneNumber = entity.phoneNumber
      ..reason = entity.reason
      ..requestType = entity.requestType;
  }

  RequestEntity build();
}
