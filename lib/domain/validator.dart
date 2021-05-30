/// [Validator] can check entity fields for correct values.
abstract class Validator<T> {
  const Validator();

  /// Validates [entity] fields and returns [Iterable] of errors.
  /// If [entity] is valid returning [Iterable] will empty.
  Iterable<String> validate(T entity);

  /// Validates [entity] fields. Completed normally if [entity] if valid.
  /// Throws [ValidationError] if [entity] has errors.
  void ensureValid(T entity) {
    final errors = validate(entity).toList(growable: false);
    if (errors.isNotEmpty) {
      throw ValidationError(errors);
    }
  }

  /// Returns `true` if all elements in list are valid
  bool isValid(Iterable<T> data) =>
      data.every((element) => validate(element).isEmpty);
}

/// Used to signal that validated entity is invalid
class ValidationError implements Exception {
  /// List of validation errors
  final List<String> errors;

  const ValidationError(this.errors);
}
