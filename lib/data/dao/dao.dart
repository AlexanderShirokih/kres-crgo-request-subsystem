import 'package:kres_requests2/data/repository/persisted_object.dart';

/// Data access object for [Employee] objects
abstract class Dao<E, PE extends PersistedObject<int>> {
  /// Inserts [entity] to the storage
  Future<PE> insert(E entity);

  /// Finds all employees persisting in the storage
  Future<List<PE>> findAll();

  /// Updates [entity] record in the storage
  Future<void> update(PE entity);

  /// Deletes [entity] record from the storage
  Future<void> delete(PE entity);
}
