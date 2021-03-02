import 'package:kres_requests2/data/dao/position_dao.dart';
import 'package:kres_requests2/data/models/employee.dart';
import 'package:kres_requests2/data/persistence_exception.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'dao.dart';

extension EmployeeEncoder on Employee {
  /// Converts [Employee] instance to JSON representation
  Map<String, dynamic> toMap() {
    // Cascading is not allowed, so position should be already inserted
    if (position is! PersistedObject<int>) {
      throw PersistenceException.notPersisted();
    }

    return {
      if (this is PersistedObject<int>) 'id': (this as PersistedObject<int>).id,
      'name': name,
      'position_id': (position as PersistedObject<int>).id,
      'access_group': accessGroup,
    };
  }
}

/// Data access object for [Employee] objects
class EmployeeDao implements Dao<Employee, EmployeeEntity> {
  static const _table = 'employee';

  final Database _database;

  final PositionDao _positionDao;

  const EmployeeDao(this._database, this._positionDao);

  /// Inserts [Employee] to the storage
  @override
  Future<EmployeeEntity> insert(Employee employee) async {
    return EmployeeEntity(
      await _database.insert(_table, employee.toMap()),
      name: employee.name,
      position: employee.position,
      accessGroup: employee.accessGroup,
    );
  }

  /// Finds all employees persisting in the storage
  @override
  Future<List<EmployeeEntity>> findAll() async {
    final data = await _database.query(_table);

    return await _unwrap(data).toList();
  }

  /// Updates [Employee] record in the storage
  @override
  Future<void> update(EmployeeEntity employee) async {
    await _database.update(_table, employee.toMap());
  }

  /// Deletes [Employee] record from the storage
  @override
  Future<void> delete(EmployeeEntity employee) async {
    await _database.delete(_table, where: 'id = ?', whereArgs: [employee.id]);
  }

  Stream<EmployeeEntity> _unwrap(List<Map<String, dynamic>> result) async* {
    for (final data in result) {
      // TODO: Proxy this call: cache results
      final position = await _positionDao.findById(data['position_id']);

      yield EmployeeEntity(
        data['id'],
        name: data['name'],
        accessGroup: data['access_group'],
        position: position,
      );
    }
  }
}
