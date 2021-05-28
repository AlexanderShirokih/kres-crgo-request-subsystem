import 'package:kres_requests2/domain/validator.dart';

/// Data class wrapping validator and it's field selector
class ValidationEntry<E> {
  /// Field name
  final String name;

  /// Validator instance
  final Validator validator;

  /// Field selector
  final dynamic Function(E) fieldSelector;

  const ValidationEntry(this.name, this.validator, this.fieldSelector);
}

/// [Validator] that assigns validators to fields
class MappedValidator<E> extends Validator<E> {
  final List<ValidationEntry<E>> _validators;

  const MappedValidator(this._validators);

  @override
  Iterable<String> validate(E entity) sync* {
    for (final entry in _validators) {
      yield* entry.validator
          .validate(entry.fieldSelector(entity))
          .map((e) => entry.name + ": " + e);
    }
  }

  V findValidator<V extends Validator>(String fieldName) =>
      _validators.singleWhere((e) => e.name == fieldName).validator as V;
}
