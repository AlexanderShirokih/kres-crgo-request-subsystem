import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/data/repository/request_repository.dart';
import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/data/validators/request_validator.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/lazy.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// DI Module that contains [RequestEntity] related dependencies
class RequestModule {
  RequestModule();

  final Lazy<StreamedRepositoryController<RequestEntity>>
      _lazyRequestController = Lazy();

  AbstractRepositoryController<RequestEntity> get requestController =>
      _lazyRequestController.call(
        () => StreamedRepositoryController(
          RepositoryController(
              _StubbedRequestEntityBuilder(), requestRepository),
        ),
      );

  Repository<RequestEntity> get requestRepository =>
      PageRequestRepository();

  MappedValidator<RequestEntity> get requestValidator => RequestValidator();
}

class _StubbedRequestEntityBuilder
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
          counterInfo: request.counterInfo,
          accountId: request.accountId,
          reason: request.reason,
          requestType: request.requestType,
        );

  @override
  get id => ++_internalId;
}
