import 'package:kres_requests2/data/models/employee.dart';

/// Repository interface for managing [Employee]
abstract class EmployeeRepository {
  /// Inserts [Employee] to the storage
  Future<void> insert(Employee employee);

  /// Updates [Employee] record in the storage
  Future<void> update(Employee employee);

  /// Deletes [Employee] record from the storage
  Future<void> delete(Employee employee);

  /// Finds all employees persisting in the storage
  Future<List<Employee>> getAll();

  Future<List<Employee>> getAllByMinGroup(int minGroup) async {
    final employees = await getAll();
    return employees
        .where((element) => element.accessGroup >= minGroup)
        .toList();
  }
}
