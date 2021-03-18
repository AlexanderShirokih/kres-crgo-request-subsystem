import 'package:kres_requests2/data/dao/request_type_dao.dart';
import 'package:kres_requests2/data/database_module.dart';
import 'package:kres_requests2/data/models/request_type.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/data/validators/request_type_validator.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/lazy.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/repository/repository.dart';

/// DI Module that contains [RequestType] related dependencies
class RequestTypeModule {
  final DatabaseModule _databaseModule;

  Lazy<RequestTypeDao> _requestTypeDao = Lazy();

  Lazy<Repository<RequestType>> _requestTypeRepository = Lazy();

  RequestTypeModule(this._databaseModule);

  RequestTypeDao get requestTypeDao =>
      _requestTypeDao.call(() => RequestTypeDao(_databaseModule.database));

  Repository<RequestType> get requestTypeRepository => _requestTypeRepository
      .call(() => PersistedStorageRepository(requestTypeDao));

  StreamedRepositoryController<RequestType> get requestTypeController =>
      StreamedRepositoryController(
          RepositoryController(_persistedObjectBuilder, requestTypeRepository));

  PersistedObjectBuilder<RequestType> get _persistedObjectBuilder =>
      RequestTypePersistedBuilder();

  /// Returns [RequestTypeValidator] for validating [RequestType] fields
  MappedValidator<RequestType> get requestTypeValidator =>
      RequestTypeValidator();
}
