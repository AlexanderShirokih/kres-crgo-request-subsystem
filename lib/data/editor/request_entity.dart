import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// Adapter to [PersistedObjectBuilder] for [RequestEntity]
class StubbedRequestEntityBuilder
    implements PersistedObjectBuilder<RequestEntity> {
  @override
  RequestEntity build(key, RequestEntity entity) =>
      _PersistedRequestEntity(entity);
}

class _PersistedRequestEntity extends RequestEntity implements PersistedObject {
  static int _internalId = 0;

  _PersistedRequestEntity(RequestEntity request)
      : super(
          name: request.name,
          address: request.address,
          additionalInfo: request.additionalInfo,
          counter: request.counter,
          accountId: request.accountId,
          reason: request.reason,
          requestType: request.requestType,
        );

  @override
  get id => ++_internalId;
}
