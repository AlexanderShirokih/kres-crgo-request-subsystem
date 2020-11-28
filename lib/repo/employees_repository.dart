import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/repo/caching_crud_repository.dart';

/// Repository class for managing [Employee]s
class EmployeesRepository extends CachingCRUDRepository<Employee> {
  EmployeesRepository(ApiServer apiServer)
      : super(const Duration(hours: 1), apiServer, Employee.encoder(),
            'employees');
}
