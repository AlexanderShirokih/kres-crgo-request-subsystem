import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/validators.dart';

/// [Validator] implementation that validates position instances
class PositionValidator extends MappedValidator<Position> {
  /// Creates new [PositionValidator] instance
  PositionValidator()
      : super([
          ValidationEntry(
              'name',
              const StringValidator(
                minLength: 3,
                maxLength: 20,
              ),
              (p) => p.name),
        ]);
}
