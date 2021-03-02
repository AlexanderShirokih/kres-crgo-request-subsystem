import 'package:kres_requests2/data/dao/employee_dao.dart';
import 'package:kres_requests2/data/database_module.dart';
import 'package:kres_requests2/data/models/employee.dart';
import 'package:kres_requests2/data/settings/position_module.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/lazy.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/repository/employee_repository.dart';
import 'package:kres_requests2/domain/validator.dart';

import 'validators/employee_validators.dart';

/// DI Module that contains [Employee] related dependencies
class EmployeeModule {
  final DatabaseModule _databaseModule;
  final PositionModule _positionModule;

  Lazy<EmployeeDao> _employeeDao = Lazy();

  Lazy<EmployeeRepository> _employeeRepository = Lazy();

  EmployeeModule(this._databaseModule, this._positionModule);

  /// Returns [EmployeeRepository] instance
  EmployeeRepository get employeeRepository => _employeeRepository.call(
        () => EmployeeRepository(
          _employeeDao.call(
            () => EmployeeDao(
                _databaseModule.database, _positionModule.positionDao),
          ),
        ),
      );

  StreamedRepositoryController<Employee> get employeeController =>
      StreamedRepositoryController(
          RepositoryController(_persistedObjectBuilder, employeeRepository));

  PersistedObjectBuilder<Employee> get _persistedObjectBuilder =>
      EmployeePersistedBuilder();

  /// Returns [EmployeeValidator] for validating [Employee] fields
  Validator<Employee> get employeeValidator => EmployeeValidator();
}
