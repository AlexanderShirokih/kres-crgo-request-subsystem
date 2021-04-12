import 'package:kres_requests2/domain/validator.dart';

/// [Validator] that validates String field using regexp
class RegexpValidator extends Validator<String> {
  final RegExp regExp;

  const RegexpValidator(this.regExp);

  @override
  Iterable<String> validate(String entity) sync* {
    // TODO: move hardcoded strings to i18n file
    if (!regExp.hasMatch(entity)) {
      yield 'Поле не соответствует шаблону!';
    }
  }
}
