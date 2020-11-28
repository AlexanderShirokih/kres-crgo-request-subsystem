import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/repo/districts_repository.dart';
import 'package:kres_requests2/repo/positions_repository.dart';
import 'package:kres_requests2/repo/request_set_repository.dart';
import 'package:kres_requests2/repo/request_types_repository.dart';
import 'package:kres_requests2/repo/street_repository.dart';
import 'package:kres_requests2/repo/users_repository.dart';
import 'package:kres_requests2/utils/lazy.dart';
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

import 'counter_types_repository.dart';

/// Repository injection point
class RepositoryModule {
  final ConfigRepository _configRepository;
  final SettingsRepository _settingsRepository;
  final RequestsRepository _requestsRepository;
  final CountersImporterRepository _countersRepository;

  final ApiServer _apiServer;
  final CredentialsManager _credentialsManager;

  final Lazy<PositionsRepository> _positionsRepository = Lazy();
  final Lazy<EmployeesRepository> _employeeRepository = Lazy();
  final Lazy<StreetRepository> _streetRepository = Lazy();
  final Lazy<CounterTypesRepository> _counterTypesRepository = Lazy();

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

    final countersRepo = CountersImporterRepository(
      importer: CountersImporter(configRepo),
    );

    return RepositoryModule._(
      configRepo,
      settingsRepo,
      requestsRepo,
      countersRepo,
      apiServer,
      credentialsManager,
    );
  }

  RepositoryModule._(
    this._configRepository,
    this._settingsRepository,
    this._requestsRepository,
    this._countersRepository,
    this._apiServer,
    this._credentialsManager,
  );

  RequestsRepository getRequestsRepository() => _requestsRepository;

  SettingsRepository getSettingsRepository() => _settingsRepository;

  ConfigRepository getConfigRepository() => _configRepository;

  CountersImporterRepository getCountersImporterRepository() =>
      _countersRepository;

  UsersRepository getUserRepository() =>
      UsersRepository(_apiServer, _credentialsManager);

  RequestsSetRepository getRequestSetRepository() =>
      RequestsSetRepository(_apiServer);

  RequestTypeRepository getRequestTypeRepository() =>
      RequestTypeRepository(_apiServer);

  PositionsRepository getPositionsRepository() =>
      _positionsRepository.getValue(() => PositionsRepository(_apiServer));

  EmployeesRepository getEmployeesRepository() =>
      _employeeRepository.getValue(() => EmployeesRepository(_apiServer));

  StreetRepository getStreetRepository() =>
      _streetRepository.getValue(() => StreetRepository(_apiServer));

  DistrictRepository getDistrictRepository() => DistrictRepository(_apiServer);

  CredentialsManager getCredentialsManager() => _credentialsManager;

  CounterTypesRepository getCounterTypesRepository() => _counterTypesRepository
      .getValue(() => CounterTypesRepository(_apiServer));
}
