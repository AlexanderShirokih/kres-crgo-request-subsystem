/// Base class for repositories that provides unified access to data
abstract class Repository<T> {
  /// Adds object to the storage
  Future<T> add(T entity);

  /// Updates existing entity in the database
  Future<void> update(T entity);

  /// Deletes object from storage
  Future<void> delete(T entity);

  /// Gets all objects from the storage as list
  Future<List<T>> getAll();

  /// Called when controller commits changes that was previously made
  Future<void> onCommit() => Future.value();
}
