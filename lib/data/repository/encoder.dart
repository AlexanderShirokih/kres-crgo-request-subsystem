import 'package:kres_requests2/data/repository/persisted_object.dart';

/// Class responsible for encoding objects from map to object and back
abstract class PersistedObjectSerializer<E, PE extends PersistedObject> {
  const PersistedObjectSerializer();

  /// Stores entity fields to map
  Map<String, dynamic> serialize(E entity);

  /// Created new persisted entity from mapped [data]
  Future<PersistedObject> deserialize(Map<String, dynamic> data);
}
