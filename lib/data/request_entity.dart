import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Describes information about work request
class RequestEntity extends Equatable {
  /// An account number (up to 6 digit)
  final int accountId;

  /// Requester name
  final String name;

  /// Requester address
  final String address;

  /// A request type
  final String reqType;

  /// Full request type
  final String fullReqType;

  /// Additional info, such as additionalInfo, phone number, connection point
  final String additionalInfo;

  /// Electrical counter info
  final String counterInfo;

  const RequestEntity({
    @required this.name,
    @required this.address,
    @required this.counterInfo,
    @required this.additionalInfo,
    this.accountId,
    this.reqType,
    this.fullReqType,
  })  : assert(name != null),
        assert(address != null),
        assert(counterInfo != null),
        assert(additionalInfo != null);

  /// Creates [RequestEntity] instance from JSON
  factory RequestEntity.fromJson(Map<String, dynamic> data) => RequestEntity(
        accountId: data['accountId'],
        name: data['name'],
        address: data['address'],
        reqType: data['reqType'],
        fullReqType: data['fullReqType'],
        additionalInfo: data['additionalInfo'],
        counterInfo: data['counterInfo'],
      );

  factory RequestEntity.empty() => RequestEntity(
        name: "",
        address: "",
        counterInfo: "",
        additionalInfo: "",
        accountId: null,
      );

  /// Creates a copy of object with specifying parameters
  RequestEntity copy({
    int accountId,
    String name,
    String address,
    String reqType,
    String fullReqType,
    String counterInfo,
    String additionalInfo,
  }) =>
      RequestEntity(
        accountId: accountId ?? this.accountId,
        name: name ?? this.name,
        address: address ?? this.address,
        reqType: reqType ?? this.reqType,
        additionalInfo: additionalInfo ?? this.additionalInfo,
        counterInfo: counterInfo ?? this.counterInfo,
        fullReqType: fullReqType ?? this.reqType,
      );

  @override
  List<Object> get props => [
        accountId,
        name,
        address,
        reqType,
        fullReqType,
        additionalInfo,
        counterInfo,
      ];
}
