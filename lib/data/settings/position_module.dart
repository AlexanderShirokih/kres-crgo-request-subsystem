import 'package:kres_requests2/data/dao/position_dao.dart';
import 'package:kres_requests2/data/database_module.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
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
}
