import 'package:kres_requests2/data/repository/encoder.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:meta/meta.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Data access object for [Employee] objects
abstract class Dao<E, PE extends PersistedObject<int>> {
  /// Finds entity by [id].
  /// Returns `null` if there is no position entity with given [id].
  Future<PE?> findById(int id);

  /// Inserts [entity] to the storage
  Future<PE> insert(E entity);

  /// Finds all employees persisting in the storage
  Future<List<PE>> findAll();

  /// Updates [entity] record in the storage
  Future<void> update(PE entity);

  /// Deletes [entity] record from the storage
  Future<void> delete(PE entity);
}

class BaseDao<E, PE extends PersistedObject<int>> implements Dao<E, PE> {
  final PersistedObjectSerializer<E, PE> _objectSerializer;

  @protected
  final Database database;

  @protected
  final String tableName;

  const BaseDao(
    this._objectSerializer, {
    required this.tableName,
    required this.database,
  });

  @override
  Future<PE?> findById(int id) async {
    final result =
        await database.query(tableName, where: 'id = ?', whereArgs: [id]);
    try {
      return _unwrap(result).first;
    } on StateError {
      return null;
    }
  }

  @override
  Future<PE> insert(E entity) async {
    final serializedData = _objectSerializer.serialize(entity);
    serializedData['id'] = await database.insert(tableName, serializedData);
    return (await _objectSerializer.deserialize(serializedData)) as PE;
  }

  @override
  Future<void> delete(PE entity) async {
    await database.delete(tableName, where: 'id = ?', whereArgs: [entity.id]);
  }

  @override
  Future<List<PE>> findAll() async {
    final data = await database.query(tableName);
    return _unwrap(data).toList();
  }

  @override
  Future<void> update(PE entity) async {
    await database.update(
      tableName,
      _objectSerializer.serialize(entity as E)..remove('id'),
      where: 'id=?',
      whereArgs: [entity.id],
    );
  }

  @protected
  Stream<PE> _unwrap(List<Map<String, dynamic>> result) =>
      Stream.fromFutures(result.map(_objectSerializer.deserialize)).cast<PE>();
}
