import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/validator.dart';

/// [Validator] implementation that validates employee instances
class EmployeeValidator extends Validator<Employee> {
  @override
  Iterable<ValidationResult> validate(Employee entity) sync* {
    // TODO: Localize!
    if (entity.name.isEmpty) {
      yield ValidationResult(
          errorMessage: 'employee.name.empty', fieldName: 'name');
    }

    if (entity.name.length < 3 || entity.name.length > 50) {
      yield ValidationResult(errorMessage: '', fieldName: 'name');
    }
  }
}
