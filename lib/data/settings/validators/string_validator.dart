import 'package:kres_requests2/domain/validator.dart';

/// [Validator] that validates String field in its length
class StringValidator extends Validator<String> {
  /// `true` if field can be empty
  final bool canBeEmpty;

  /// Minimal string length
  final int minLength;

  /// Maximal string length
  final int maxLength;

  /// Field name for describing in [ValidationResult]
  final String fieldName;

  const StringValidator({
    this.canBeEmpty = false,
    required this.fieldName,
    required this.minLength,
    required this.maxLength,
  });

  @override
  Iterable<ValidationResult> validate(String entity) sync* {
    // TODO: move hardcoded strings to i18n file
    if (entity.isEmpty && !canBeEmpty) {
      yield ValidationResult(
        errorMessage: 'Поле не должно быть пустым!',
        fieldName: fieldName,
      );
    } else if (entity.length < minLength || entity.length > maxLength) {
      yield ValidationResult(
        errorMessage: 'Требуется от $minLength до $maxLength символов',
        fieldName: fieldName,
      );
    }
  }
}
