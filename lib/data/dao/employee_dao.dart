import 'package:kres_requests2/data/models/employee.dart';
import 'package:kres_requests2/data/models/position.dart';
import 'package:kres_requests2/data/persistence_exception.dart';
import 'package:kres_requests2/data/repository/encoder.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'dao.dart';

class EmployeeEncoder
    implements PersistedObjectSerializer<Employee, EmployeeEntity> {
  final Dao<Position, PositionEntity> _positionDao;

  const EmployeeEncoder(this._positionDao);

  @override
  Future<PersistedObject> deserialize(Map<String, dynamic> data) async {
    // TODO: Proxy this call: cache results
    final position = await _positionDao.findById(data['position_id']);

    return EmployeeEntity(
      data['id'],
      name: data['name'],
      accessGroup: data['access_group'],
      position: position ?? const PositionEntity(0, name: '???'),
    );
  }

  @override
  Map<String, dynamic> serialize(Employee entity) {
    // Cascading is not allowed, so position should be already inserted
    if (entity.position is! PersistedObject<int>) {
      throw PersistenceException.notPersisted();
    }

    return {
      if (this is PersistedObject<int>) 'id': (this as PersistedObject<int>).id,
      'name': entity.name,
      'position_id': (entity.position as PersistedObject<int>).id,
      'access_group': entity.accessGroup,
    };
  }
}

/// Data access object for [Employee] objects
class EmployeeDao extends BaseDao<Employee, EmployeeEntity> {
  EmployeeDao(Database database, Dao<Position, PositionEntity> positionDao)
      : super(
          EmployeeEncoder(positionDao),
          tableName: 'employee',
          database: database,
        );
}
