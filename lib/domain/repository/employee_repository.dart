import 'package:kres_requests2/data/dao/dao.dart';
import 'package:kres_requests2/data/models/employee.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
import 'package:kres_requests2/domain/models/employee.dart';

/// Repository interface for managing [Employee]s
class EmployeeRepository
    extends PersistedStorageRepository<Employee, EmployeeEntity> {
  EmployeeRepository(Dao<Employee, EmployeeEntity> employeeDao)
      : super(employeeDao);

  /// Returns all employees which have access group at least [minGroup]
  Future<List<Employee>> getAllByMinGroup(int minGroup) async {
    final employees = await getAll();
    return employees
        .where((element) => element.accessGroup >= minGroup)
        .toList();
  }
}
