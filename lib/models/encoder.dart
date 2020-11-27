/// Converts object to JSON and vice versa
abstract class Encoder<E> {
  /// Converts JSON representation to entity instance
  E fromJson(Map<String, dynamic> data);

  /// Converts entity instance to its JSON representation
  Map<String, dynamic> toJson(E entity);
}
