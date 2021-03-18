import 'package:kres_requests2/data/dao/position_dao.dart';
import 'package:kres_requests2/data/database_module.dart';
import 'package:kres_requests2/data/models/position.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/data/validators/position_validator.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/lazy.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/repository/repository.dart';

/// DI Module that contains [Position] related dependencies
class PositionModule {
  final DatabaseModule _databaseModule;

  Lazy<PositionDao> _positionDao = Lazy();

  Lazy<Repository<Position>> _positionRepository = Lazy();

  PositionModule(this._databaseModule);

  PositionDao get positionDao =>
      _positionDao.call(() => PositionDao(_databaseModule.database));

  Repository<Position> get positionRepository =>
      _positionRepository.call(() => PersistedStorageRepository(positionDao));

  StreamedRepositoryController<Position> get positionController =>
      StreamedRepositoryController(
          RepositoryController(_persistedObjectBuilder, positionRepository));

  PersistedObjectBuilder<Position> get _persistedObjectBuilder =>
      PositionPersistedBuilder();

  /// Returns [PositionValidator] for validating [Position] fields
  MappedValidator<Position> get positionValidator => PositionValidator();
}
