import 'package:kres_requests2/data/dao/employee_dao.dart';
import 'package:kres_requests2/data/repository/storage_employee_repository.dart';
import 'package:kres_requests2/domain/repository/employee_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kres_requests2/data/java_process_executor.dart';
import 'package:kres_requests2/data/models/java_process_info.dart';
import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/repo/config_repository.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';

/// Repository injection point
class RepositoryModule {
  final ConfigRepository _configRepository;
  final SettingsRepository _settingsRepository;
  final RequestsRepository _requestsRepository;
  final EmployeeRepository _employeeRepository;
  final CountersImporterRepository _countersRepository;
  final NativeImporterRepository _nativeImporterRepository;

  static Future<RepositoryModule> buildRepositoryModule() async {
    final settingsRepo = SettingsRepository.fromPreferences(
      await SharedPreferences.getInstance(),
    );

    final configRepo = await ConfigRepository.create();

    final requestsRepo = RequestsRepository(
      RequestProcessorImpl(
        JavaProcessExecutor(
          javaHome: () => settingsRepo.javaPath,
          javaProcessInfo:
              JavaProcessInfo.fromMap(configRepo.getRequestsProcessInfoData()),
        ),
      ),
    );

    final employeeRepo = StorageEmployeeRepository(EmployeeDao());

    final countersRepo = CountersImporterRepository(
      importer: CountersImporter(configRepo),
    );

    final nativeImporterRepo = NativeImporterRepository();

    return RepositoryModule._(
      configRepo,
      settingsRepo,
      requestsRepo,
      employeeRepo,
      countersRepo,
      nativeImporterRepo,
    );
  }

  RepositoryModule._(
    this._configRepository,
    this._settingsRepository,
    this._requestsRepository,
    this._employeeRepository,
    this._countersRepository,
    this._nativeImporterRepository,
  );

  RequestsRepository getRequestsRepository() => _requestsRepository;

  SettingsRepository getSettingsRepository() => _settingsRepository;

  ConfigRepository getConfigRepository() => _configRepository;

  EmployeeRepository getEmployeesRepository() => _employeeRepository;

  CountersImporterRepository getCountersImporterRepository() =>
      _countersRepository;

  NativeImporterRepository getNativeImporterRepository() =>
      _nativeImporterRepository;
}
