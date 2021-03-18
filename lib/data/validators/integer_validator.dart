import 'package:kres_requests2/domain/validator.dart';

/// [Validator] that validates integer fields
class IntegerValidator extends Validator<int?> {
  /// Minimal integer value (inclusive)
  final int? min;

  /// Maximal integer value (inclusive)
  final int? max;

  /// Can field accept null values?
  final bool canBeNull;

  /// Field name for describing in [ValidationError]
  final String fieldName;

  const IntegerValidator({
    this.canBeNull = false,
    this.min,
    this.max,
    required this.fieldName,
  });

  @override
  Iterable<String> validate(int? entity) sync* {
    // TODO: move hardcoded strings to i18n file
    if (entity == null && !canBeNull) {
      yield 'Поле не должно быть пустым';
    } else {
      final val = entity!;
      if (min != null && val < min!) {
        yield 'Значение должно быть больше $min';
      }

      if (max != null && val > max!) {
        yield 'Значение должно быть меньше $max';
      }
    }
  }
}
