import 'package:kres_requests2/data/employee.dart';

class EmployeesRepository {
  final List<Employee> _allEmployees;

  const EmployeesRepository(this._allEmployees);

  List<Employee> getAllEmployees() => List.unmodifiable(_allEmployees);

  List<Employee> getAllByMinGroup(int minGroup) => getAllEmployees()
      .where((element) => element.accessGroup >= minGroup)
      .toList();
}
