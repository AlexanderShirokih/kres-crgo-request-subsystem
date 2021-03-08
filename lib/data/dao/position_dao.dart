import 'package:kres_requests2/data/models/position.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'dao.dart';

extension PositionEncoder on Position {
  /// Converts [Position] instance to JSON representation
  Map<String, dynamic> toMap({bool putIds = true}) => {
        if (this is PersistedObject<int>)
          'id': (this as PersistedObject<int>).id,
        'name': name,
      };
}

/// Data access object for [Position] objects
class PositionDao implements Dao<Position, PositionEntity> {
  static const _table = 'employee_position';

  final Database _database;

  const PositionDao(this._database);

  /// Inserts [Position] to the storage
  @override
  Future<PositionEntity> insert(Position position) async {
    return PositionEntity(
      await _database.insert(_table, position.toMap()),
      name: position.name,
    );
  }

  /// Finds all positions persisting in the storage
  @override
  Future<List<PositionEntity>> findAll() async {
    final data = await _database.query(_table);
    return _unwrap(data).toList();
  }

  /// Updates [Position] record in the storage
  @override
  Future<void> update(PositionEntity position) async {
    await _database.update(
      _table,
      position.toMap(putIds: false),
      where: 'id=?',
      whereArgs: [position.id],
    );
  }

  /// Deletes [Position] record from the storage
  @override
  Future<void> delete(PositionEntity position) async {
    await _database.delete(_table, where: 'id = ?', whereArgs: [position.id]);
  }

  Future<PositionEntity> findById(int id) async {
    final result =
        await _database.query(_table, where: 'id = ?', whereArgs: [id]);

    return _unwrap(result).first;
  }

  Iterable<PositionEntity> _unwrap(List<Map<String, dynamic>> result) =>
      result.map(
        (data) => PositionEntity(
          data['id'],
          name: data['name'],
        ),
      );
}
