import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/models/connection_point.dart';
import 'package:kres_requests2/domain/models/counter_info.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';

/// Request entity implementation that uses internal ID as [PersistedObject]
class RequestEntityImpl extends RequestEntity implements PersistedObject<int> {
  @override
  final int id;

  RequestEntityImpl({
    required this.id,
    String address = '',
    String name = '',
    CounterInfo? counter,
    String? additionalInfo,
    String? phoneNumber,
    int? accountId,
    ConnectionPoint? connectionPoint,
    RequestType? requestType,
    String? reason,
  }) : super(
          name: name,
          additionalInfo: additionalInfo,
          address: address,
          counter: counter,
          accountId: accountId,
          connectionPoint: connectionPoint,
          phoneNumber: phoneNumber,
          reason: reason,
          requestType: requestType,
        );

  @override
  RequestEntity rebuild({
    required int? accountId,
    required String name,
    required ConnectionPoint? connectionPoint,
    required String? additionalInfo,
    required RequestType? requestType,
    required String? phoneNumber,
    required CounterInfo? counter,
    required String address,
    required String? reason,
  }) =>
      RequestEntityImpl(
        id: this.id,
        name: name,
        address: address,
        reason: reason,
        counter: counter,
        accountId: accountId,
        requestType: requestType,
        phoneNumber: phoneNumber,
        additionalInfo: additionalInfo,
        connectionPoint: connectionPoint,
      );

  @override
  List<Object?> get props => [id, ...super.props];
}
