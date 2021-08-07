import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/domain/repository/settings_repository.dart';
import 'package:kres_requests2/domain/service/dialog_service.dart';
import 'package:kres_requests2/domain/usecases/storage/database_path.dart';
import 'package:kres_requests2/presentation/startup/startup_module.dart';

/// Root application module
class AppModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.factory(
      (i) => GetDatabasePath(i<SettingsRepository>()),
    ),
    Bind.factory(
      (i) => UpdateDatabasePath(i<SettingsRepository>()),
    ),
    Bind.singleton((_) => SettingsRepository.fromPreferences()),
    Bind.singleton((i) => AppDatabase(i<GetDatabasePath>())),
    Bind.singleton((i) => DialogService()),
  ];

  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/', module: StartupModule()),
  ];
}
