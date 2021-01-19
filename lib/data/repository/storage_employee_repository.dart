import 'package:kres_requests2/data/dao/employee_dao.dart';
import 'package:kres_requests2/data/models/employee.dart';
import 'package:kres_requests2/domain/repository/employee_repository.dart';

/// Implements employee repository for persisting objects in the database
class StorageEmployeeRepository extends EmployeeRepository {
  final EmployeeDao _employeeDao;

  StorageEmployeeRepository(this._employeeDao);

  @override
  Future<void> delete(Employee employee) => _employeeDao.delete(employee);

  @override
  Future<List<Employee>> getAll() => _employeeDao.findAll();

  @override
  Future<void> insert(Employee employee) => _employeeDao.insert(employee);

  @override
  Future<void> update(Employee employee) => _employeeDao.update(employee);
}
