import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/domain/repository/settings_repository.dart';
import 'package:kres_requests2/domain/service/dialog_service.dart';
import 'package:kres_requests2/presentation/startup/startup_module.dart';

/// Root application module
class AppModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.singleton((_) => AppDatabase.instance),
    Bind.singleton((_) => SettingsRepository.fromPreferences()),
    Bind.singleton((i) => DialogService()),
  ];

  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/', module: StartupModule()),
  ];
}
