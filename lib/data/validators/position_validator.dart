import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/data/validators/string_validator.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/validator.dart';

/// [Validator] implementation that validates position instances
class PositionValidator extends MappedValidator<Position> {
  /// Creates new [PositionValidator] instance
  PositionValidator()
      : super({
          const StringValidator(
            fieldName: 'name',
            minLength: 3,
            maxLength: 20,
          ): (p) => p.name,
        });
}
