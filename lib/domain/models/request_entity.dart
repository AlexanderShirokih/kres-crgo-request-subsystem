import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models/connection_point.dart';
import 'package:kres_requests2/domain/models/counter_info.dart';
import 'package:kres_requests2/domain/models/request_type.dart';

/// Describes information about work request
abstract class Request extends Equatable {
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

  const Request({
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

  /// Unique request id
  int get id;

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

  /// Creates a new object by replacing all fields
  Request rebuild({
    required int? accountId,
    required String name,
    required ConnectionPoint? connectionPoint,
    required String? additionalInfo,
    required RequestType? requestType,
    required String? phoneNumber,
    required CounterInfo? counter,
    required String address,
    required String? reason,
  });

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
