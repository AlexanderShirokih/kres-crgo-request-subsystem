import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/data/repository/encoder.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:meta/meta.dart';

/// Base data access object
abstract class Dao<E, PE extends PersistedObject<int>> {
  /// Finds the last item by ordering by [id]
  Future<PE?> findLast();

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

  /// Returns count of table entries
  Future<int> count();
}

class BaseDao<E, PE extends PersistedObject<int>> implements Dao<E, PE> {
  final PersistedObjectSerializer<E, PE> _objectSerializer;

  @protected
  final AppDatabase database;

  @protected
  final String tableName;

  const BaseDao(
    this._objectSerializer, {
    required this.tableName,
    required this.database,
  });

  @override
  Future<PE?> findLast() async {
    final db = await database.database;
    final result =
        await db.rawQuery('SELECT * FROM $tableName ORDER BY id DESC LIMIT 1');
    try {
      return await _unwrap(result).first;
    } on StateError {
      return null;
    }
  }

  @override
  Future<PE?> findById(int id) async {
    final db = await database.database;
    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    try {
      return await _unwrap(result).first;
    } on StateError {
      return null;
    }
  }

  @override
  Future<int> count() async {
    final db = await database.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM $tableName');
    final row = result.first;
    return row.values.first as int;
  }

  @override
  Future<PE> insert(E entity) async {
    final serializedData = _objectSerializer.serialize(entity);
    final db = await database.database;
    serializedData['id'] = await db.insert(tableName, serializedData);
    return (await _objectSerializer.deserialize(serializedData)) as PE;
  }

  @override
  Future<void> delete(PE entity) async {
    final db = await database.database;
    await db.delete(tableName, where: 'id = ?', whereArgs: [entity.id]);
  }

  @override
  Future<List<PE>> findAll() async {
    final db = await database.database;
    final data = await db.query(tableName);
    return await _unwrap(data).toList();
  }

  @override
  Future<void> update(PE entity) async {
    final db = await database.database;
    await db.update(
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
