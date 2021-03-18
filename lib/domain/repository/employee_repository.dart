import 'package:kres_requests2/data/dao/employee_dao.dart';
import 'package:kres_requests2/data/models/employee.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
import 'package:kres_requests2/domain/models/employee.dart';

/// Repository interface for managing [Employee]s
class EmployeeRepository
    extends PersistedStorageRepository<Employee, EmployeeEntity> {
  EmployeeRepository(EmployeeDao employeeDao) : super(employeeDao);

  Future<List<Employee>> getAllByMinGroup(int minGroup) async {
    final employees = await getAll();
    return employees
        .where((element) => element.accessGroup >= minGroup)
        .toList();
  }
}