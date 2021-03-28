import 'package:kres_requests2/data/dao/dao.dart';
import 'package:kres_requests2/data/persistence_exception.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:meta/meta.dart';

import 'persisted_object.dart';

/// Implements employee repository for persisting objects in the database
class PersistedStorageRepository<E, PE extends PersistedObject<int>>
    extends Repository<E> {
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
  Future<E> add(E entity) async {
    return ((await dao.insert(entity)) as E);
  }

  @override
  Future<List<E>> getAll() async {
    return (await dao.findAll()).cast<E>();
  }

  @override
  Future<void> update(E entity) async {
    if (entity is PE) {
      return dao.update(entity);
    } else {
      throw PersistenceException.notPersisted();
    }
  }
}
