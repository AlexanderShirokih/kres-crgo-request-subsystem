import 'package:http/http.dart' as http;
import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/repo/districts_repository.dart';
import 'package:kres_requests2/repo/employees_repository.dart';
import 'package:kres_requests2/repo/export_repository.dart';
import 'package:kres_requests2/repo/positions_repository.dart';
import 'package:kres_requests2/repo/request_set_repository.dart';
import 'package:kres_requests2/repo/request_types_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/repo/street_repository.dart';
import 'package:kres_requests2/repo/users_repository.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';
import 'package:kres_requests2/utils/lazy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'counter_types_repository.dart';

/// Repository injection point
class RepositoryModule {
  final SettingsRepository _settingsRepository;
  final CountersImporterRepository _countersRepository;

  final ApiServer _apiServer;
  final CredentialsManager _credentialsManager;

  final Lazy<PositionsRepository> _positionsRepository = Lazy();
  final Lazy<EmployeesRepository> _employeeRepository = Lazy();
  final Lazy<StreetRepository> _streetRepository = Lazy();
  final Lazy<CounterTypesRepository> _counterTypesRepository = Lazy();

  /// Builds new instance of `RepositoryModule`
  static Future<RepositoryModule> buildRepositoryModule(
    CredentialsManager credentialsManager,
    SharedPreferences sharedPreferences,
  ) async {
    assert(credentialsManager != null);
    assert(sharedPreferences != null);

    final settingsRepo = SettingsRepository.fromPreferences(sharedPreferences);

    final countersRepo = CountersImporterRepository(
      importer: CountersImporter(),
    );

    final apiServer = ApiServer(
      http.Client(),
      settingsRepo,
      8080,
      credentialsManager,
    );

    return RepositoryModule._(
      settingsRepo,
      countersRepo,
      apiServer,
      credentialsManager,
    );
  }

  RepositoryModule._(
    this._settingsRepository,
    this._countersRepository,
    this._apiServer,
    this._credentialsManager,
  );

  SettingsRepository getSettingsRepository() => _settingsRepository;

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

  ExportRepository getExportRepository() => ExportRepository(_apiServer);
}
