/// [Validator] can check entity fields for correct values.
abstract class Validator<T> {
  /// Validates entity field and returns [Iterable] of errors.
  /// If entity is valid returning [Iterable] will empty.
  Iterable<ValidationResult> validate(T entity);

  /// Returns `true` if all elements in list are valid
  bool isValid(Iterable<T> data) =>
      data.every((element) => validate(element).isEmpty);
}

/// Describes field validation result
class ValidationResult {
  /// Field error message. `null` if field is valid.
  final String? errorMessage;

  /// Field name
  final String fieldName;

  const ValidationResult({
    this.errorMessage,
    required this.fieldName,
  });

  /// `true` if field is valid
  bool get isValid => errorMessage != null;
}
