import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/validators.dart';

/// [Validator] implementation that validates employee instances
class EmployeeValidator extends MappedValidator<Employee> {
  /// Creates new [EmployeeValidator] instance
  EmployeeValidator()
      : super([
          ValidationEntry(
            'name',
            const StringValidator(
              minLength: 3,
              maxLength: 50,
            ),
            (e) => e.name,
          )
        ]);
}
