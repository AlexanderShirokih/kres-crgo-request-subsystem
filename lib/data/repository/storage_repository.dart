import 'package:kres_requests2/data/dao/dao.dart';
import 'package:kres_requests2/data/persistence_exception.dart';
import 'package:kres_requests2/domain/repository/repository.dart';

import 'persisted_object.dart';

/// Implements employee repository for persisting objects in the database
class PersistedStorageRepository<E, PE extends PersistedObject<int>>
    extends Repository<E> {
  final Dao<E, PE> _dao;

  PersistedStorageRepository(this._dao);

  @override
  Future<void> delete(E entity) async {
    if (entity is PE) {
      return await _dao.delete(entity);
    } else {
      throw PersistenceException.notPersisted();
    }
  }

  @override
  Future<E> add(E entity) async {
    return ((await _dao.insert(entity)) as E);
  }

  @override
  Future<List<E>> getAll() async {
    return (await _dao.findAll()).cast<E>();
  }

  @override
  Future<void> update(E entity) async {
    if (entity is PE) {
      return _dao.update(entity);
    } else {
      throw PersistenceException.notPersisted();
    }
  }
}

