/// Marker interface used to add ID property to the entity
abstract class PersistedObject<PK> {
  /// Entity ID
  PK get id;
}
