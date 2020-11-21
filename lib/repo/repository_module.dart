
import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/repo/users_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kres_requests2/data/java_process_executor.dart';
import 'package:kres_requests2/data/models/java_process_info.dart';
import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/repo/config_repository.dart';
import 'package:kres_requests2/repo/employees_repository.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';

/// Repository injection point
class RepositoryModule {
  final ConfigRepository _configRepository;
  final SettingsRepository _settingsRepository;
  final RequestsRepository _requestsRepository;
  final EmployeesRepository _employeeRepository;
  final CountersImporterRepository _countersRepository;
  final NativeImporterRepository _nativeImporterRepository;

  final ApiServer _apiServer;
  final CredentialsManager _credentialsManager;

  /// Builds new instance of `RepositoryModule`
  static Future<RepositoryModule> buildRepositoryModule(
    ApiServer apiServer,
    CredentialsManager credentialsManager,
    SharedPreferences sharedPreferences,
  ) async {
    assert(apiServer != null);
    assert(credentialsManager != null);
    assert(sharedPreferences != null);

    final settingsRepo = SettingsRepository.fromPreferences(sharedPreferences);
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

    // TODO: TEMPORARY DISABLED FEATURE
    final employeeRepo = EmployeesRepository(
      // (jsonDecode(await File("employees.json").readAsString()) as List<dynamic>)
      //     .map((e) => Employee.fromJson(e))
      //     .toList(),
      [],
    );

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
      apiServer,
      credentialsManager,
    );
  }

  RepositoryModule._(
    this._configRepository,
    this._settingsRepository,
    this._requestsRepository,
    this._employeeRepository,
    this._countersRepository,
    this._nativeImporterRepository,
    this._apiServer,
    this._credentialsManager,
  );

  RequestsRepository getRequestsRepository() => _requestsRepository;

  SettingsRepository getSettingsRepository() => _settingsRepository;

  ConfigRepository getConfigRepository() => _configRepository;

  EmployeesRepository getEmployeesRepository() => _employeeRepository;

  CountersImporterRepository getCountersImporterRepository() =>
      _countersRepository;

  NativeImporterRepository getNativeImporterRepository() =>
      _nativeImporterRepository;

  UsersRepository getUserRepository() =>
      UsersRepository(_apiServer, _credentialsManager);

  CredentialsManager getCredentialsManager() => _credentialsManager;
}
