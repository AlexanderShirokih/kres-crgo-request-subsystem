import 'package:kres_requests2/domain/validator.dart';

/// [Validator] that validates String field in its length
class StringValidator extends Validator<String?> {
  /// Minimal string length
  final int minLength;

  /// Maximal string length
  final int maxLength;

  const StringValidator({
    this.minLength = 0,
    required this.maxLength,
  });

  @override
  Iterable<String> validate(String? entity) sync* {
    if (entity == null) {
      entity = '';
    }

    // TODO: move hardcoded strings to i18n file
    if (entity.isEmpty && minLength != 0) {
      yield 'Поле не должно быть пустым!';
    } else if (entity.length < minLength || entity.length > maxLength) {
      yield 'Требуется от $minLength до $maxLength символов';
    }
  }
}
