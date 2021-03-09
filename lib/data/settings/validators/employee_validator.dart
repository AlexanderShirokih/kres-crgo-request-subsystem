import 'package:kres_requests2/data/settings/validators/string_validator.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/validator.dart';

/// [Validator] implementation that validates employees instances
class EmployeeValidator extends Validator<Employee> {
  final StringValidator _nameValidator;

  /// Creates new [EmployeeValidator] instance
  EmployeeValidator()
      : _nameValidator = StringValidator(
          fieldName: 'name',
          minLength: 3,
          maxLength: 50,
        );

  @override
  Iterable<ValidationResult> validate(Employee entity) =>
      _nameValidator.validate(entity.name);
}
