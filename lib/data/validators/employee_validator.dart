import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/data/validators/string_validator.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/validator.dart';

/// [Validator] implementation that validates employees instances
class EmployeeValidator extends MappedValidator<Employee> {
  /// Creates new [EmployeeValidator] instance
  EmployeeValidator()
      : super({
          const StringValidator(
            fieldName: 'name',
            minLength: 3,
            maxLength: 50,
          ): (e) => e.name,
        });
}
