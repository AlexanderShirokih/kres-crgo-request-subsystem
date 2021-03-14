import 'package:kres_requests2/data/database_module.dart';
import 'package:kres_requests2/data/settings/employee_module.dart';
import 'package:kres_requests2/data/settings/position_module.dart';
import 'package:kres_requests2/data/settings/request_type_module.dart';
import 'package:kres_requests2/domain/lazy.dart';

class SettingsModule {
  final DatabaseModule _databaseModule;

  Lazy<EmployeeModule> _lazyEmployeeModule = Lazy();
  Lazy<PositionModule> _lazyPositionModule = Lazy();
  Lazy<RequestTypeModule> _lazyRequestTypeModule = Lazy();

  SettingsModule(this._databaseModule);

  /// [PositionModule] instance
  PositionModule get positionModule => _lazyPositionModule.call(
        () => PositionModule(_databaseModule),
      );

  /// [RequestTypeModule] instance
  RequestTypeModule get requestTypeModule => _lazyRequestTypeModule.call(
        () => RequestTypeModule(_databaseModule),
      );

  /// [EmployeeModule] instance
  EmployeeModule get employeeModule => _lazyEmployeeModule.call(
        () => EmployeeModule(_databaseModule, positionModule),
      );
}
