import 'package:kres_requests2/data/dao/dao.dart';
import 'package:kres_requests2/data/persistence_exception.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

import 'persisted_object.dart';

/// Implements employee repository for persisting objects in the database
class PersistedStorageRepository<E, PE extends PersistedObject<int>>
    extends Repository<E> {
  /// Use this object to  prevent concurrent access to data
  final writeLock = Lock();

  @protected
  final Dao<E, PE> dao;

  PersistedStorageRepository(this.dao);

  @override
  Future<void> delete(E entity) async {
    if (entity is PE) {
      return await dao.delete(entity);
    } else {
      throw PersistenceException.notPersisted();
    }
  }

  @override
  Future<E> add(E entity) {
    return writeLock.synchronized(() async => (await dao.insert(entity)) as E);
  }

  @override
  Future<List<E>> getAll() async {
    return (await dao.findAll()).cast<E>();
  }

  @override
  Future<void> update(E entity) async {
    if (entity is PE) {
      return await writeLock.synchronized(() => dao.update(entity));
    } else {
      throw PersistenceException.notPersisted();
    }
  }
}
