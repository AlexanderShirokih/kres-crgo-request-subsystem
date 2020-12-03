import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Root injection module
class ApplicationModule {
  RepositoryModule _repositoryModule;

  /// Injects all fields of `RepositoryModule`. Returns `this` instance
  Future<ApplicationModule> init(CredentialsManager credentialsManager) async {
    final sharedPreferences = await _getSharedPreferences();

    _repositoryModule = await RepositoryModule.buildRepositoryModule(credentialsManager, sharedPreferences);
    return this;
  }

  RepositoryModule getRepositoryModule() => _repositoryModule;


  Future<SharedPreferences> _getSharedPreferences() async =>
      SharedPreferences.getInstance();
}
