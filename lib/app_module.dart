import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/screens/startup/startup_module.dart';

/// Root application module
class AppModule extends Module {
  @override
  final List<Bind> binds = [
    Bind.singleton((_) => AppDatabase.instance),
  ];

  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/', module: StartupModule()),
  ];
}
