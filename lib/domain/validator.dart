/// [Validator] can check entity fields for correct values.
abstract class Validator<T> {
  const Validator();

  /// Validates entity field and returns [Iterable] of errors.
  /// If entity is valid returning [Iterable] will empty.
  Iterable<String> validate(T entity);

  /// Returns `true` if all elements in list are valid
  bool isValid(Iterable<T> data) =>
      data.every((element) => validate(element).isEmpty);
}
