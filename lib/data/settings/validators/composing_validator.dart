import 'package:kres_requests2/domain/validator.dart';

/// [Validator] that assigns validators to fields
class MappedValidator<E> extends Validator<E> {
  final Map<Validator, dynamic Function(E)> _validators;

  const MappedValidator(this._validators);

  @override
  Iterable<ValidationResult> validate(E entity) sync* {
    for (final validator in _validators.entries) {
      yield* validator.key.validate(validator.value(entity));
    }
  }
}
