import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/data/repository/config_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/screens/startup/startup_module.dart';

/// Root application module
class AppModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.singleton((_) => AppDatabase.instance),
    Bind.singleton((_) => ConfigRepository.instance),
    Bind.singleton((_) => SettingsRepository.fromPreferences()),
  ];

  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/', module: StartupModule()),
  ];
}
