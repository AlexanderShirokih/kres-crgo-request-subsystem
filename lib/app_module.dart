import 'package:kres_requests2/data/database_module.dart';

import 'repo/repository_module.dart';

/// Root application DI module
class AppModule {
  static AppModule? _instance;
  final DatabaseModule databaseModule;
  final RepositoryModule repositoryModule;

  AppModule(this.databaseModule, this.repositoryModule);

  /// Builds [AppModule] instance
  static Future<AppModule> build() async {
    return (_instance ??= AppModule(
      await DatabaseModule.build(),
      await RepositoryModule.buildRepositoryModule(),
    ));
  }
}
