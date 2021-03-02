class PersistenceException implements Exception {
  final String message;

  PersistenceException(this.message);

  factory PersistenceException.notPersisted() =>
      PersistenceException('Object is not persisted');
}
