import 'package:equatable/equatable.dart';
import 'package:kres_requests2/models/counting_point.dart';
import 'package:kres_requests2/models/account_info.dart';

/// Describes request type
class RequestType extends Equatable {
  /// Internal ID
  final int id;

  /// Short request type name
  final String shortName;

  /// Full request type name
  final String fullName;

  const RequestType({
    this.id,
    this.shortName,
    this.fullName,
  });

  static RequestType fromJson(Map<String, dynamic> data) => RequestType(
        id: data['id'],
        shortName: data['shortName'],
        fullName: data['fullName'],
      );

  @override
  List<Object> get props => [id, shortName, fullName];
}

/// Describes customer request
class Request extends Equatable {
  /// Internal request ID
  final int id;

  /// Comments to the request
  final String additional;

  /// Request initiation reason
  final String reason;

  /// Associated request type
  final RequestType requestType;

  /// Owning account info
  final AccountInfo accountInfo;

  /// Referenced counting point
  final CountingPoint countingPoint;

  const Request({
    this.id,
    this.additional,
    this.reason,
    this.requestType,
    this.accountInfo,
    this.countingPoint,
  });

  static Request fromJson(Map<String, dynamic> data) => Request(
        id: data['id'],
        additional: data['additional'],
        reason: data['reason'],
        requestType: data['requestType'] == null
            ? null
            : RequestType.fromJson(data['requestType']),
        accountInfo: data['accountInfo'] == null
            ? null
            : AccountInfo.fromJson(data['accountInfo']),
        countingPoint: data['countingPoint'] == null
            ? null
            : CountingPoint.fromJson(data['countingPoint']),
      );

  @override
  List<Object> get props => [
        id,
        additional,
        reason,
        requestType,
        accountInfo,
        countingPoint,
      ];
}
