import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/repo/repository_module.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Root injection module
class ApplicationModule {
  RepositoryModule _repositoryModule;



  /// Injects all fields of `RepositoryModule`. Returns `this` instance
  Future<ApplicationModule> init(CredentialsManager credentialsManager) async {
    final apiServer = _getApiServer();
    final sharedPreferences = await _getSharedPreferences();

    _repositoryModule = await RepositoryModule.buildRepositoryModule(
        apiServer, credentialsManager, sharedPreferences);
    return this;
  }

  RepositoryModule getRepositoryModule() => _repositoryModule;

  ApiServer _getApiServer() => ApiServer(http.Client(), 'localhost', 8080);

  Future<SharedPreferences> _getSharedPreferences() async =>
      SharedPreferences.getInstance();
}
