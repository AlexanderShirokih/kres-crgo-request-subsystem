import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/models/connection_point.dart';
import 'package:kres_requests2/domain/models/counter_info.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';

/// Adapter to [PersistedObjectBuilder] for [RequestEntity].
/// Builds persisted entities based on any default [RequestEntity]
class RequestEntityPersistedBuilder
    implements PersistedObjectBuilder<RequestEntity> {
  @override
  RequestEntity build(key, RequestEntity entity) => RequestEntityImpl(
        id: key,
        name: entity.name,
        address: entity.address,
        additionalInfo: entity.additionalInfo,
        counter: entity.counter,
        phoneNumber: entity.phoneNumber,
        connectionPoint: entity.connectionPoint,
        accountId: entity.accountId,
        reason: entity.reason,
        requestType: entity.requestType,
      );
}

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
  RequestEntityBuilder rebuild() => _RequestEntityBuilderImpl(this);

  @override
  List<Object?> get props => [id, ...super.props];
}

class _RequestEntityBuilderImpl extends RequestEntityBuilder {
  final int id;

  _RequestEntityBuilderImpl(RequestEntityImpl request)
      : id = request.id,
        super.from(request);

  @override
  RequestEntity build() => RequestEntityImpl(
        id: this.id,
        name: name ?? '',
        address: address ?? '',
        reason: reason,
        counter: counter,
        accountId: accountId,
        requestType: requestType,
        phoneNumber: phoneNumber,
        additionalInfo: additionalInfo,
        connectionPoint: connectionPoint,
      );
}
