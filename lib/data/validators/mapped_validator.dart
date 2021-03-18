import 'package:kres_requests2/data/validators/string_validator.dart';
import 'package:kres_requests2/domain/validator.dart';

/// [Validator] that assigns validators to fields
class MappedValidator<E> extends Validator<E> {
  final Map<Validator, dynamic Function(E)> _validators;

  const MappedValidator(this._validators);

  @override
  Iterable<String> validate(E entity) sync* {
    for (final validator in _validators.entries) {
      yield* validator.key.validate(validator.value(entity));
    }
  }

  StringValidator findStringValidator(String fieldName) => _validators.keys
      .whereType<StringValidator>()
      .firstWhere((element) => element.fieldName == fieldName);
}
