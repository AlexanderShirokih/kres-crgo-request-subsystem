import 'package:kres_requests2/data/settings/validators/string_validator.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/validator.dart';

/// [Validator] implementation that validates position instances
class PositionValidator extends Validator<Position> {
  final StringValidator _nameValidator;

  /// Creates new [PositionValidator] instance
  PositionValidator()
      : _nameValidator = StringValidator(
          fieldName: 'name',
          minLength: 3,
          maxLength: 20,
        );

  @override
  Iterable<ValidationResult> validate(Position entity) =>
      _nameValidator.validate(entity.name);
}
