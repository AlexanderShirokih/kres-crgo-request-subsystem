import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/models/user.dart';
import 'package:kres_requests2/repo/server_exception.dart';

/// Fetches information about users
/// TODO: Should be an interface
class UsersRepository {
  static const _kUsers = 'users';

  final CredentialsManager _credentialsManager;
  final ApiServer _apiServer;

  UsersRepository(this._apiServer, this._credentialsManager)
      : assert(_apiServer != null),
        assert(_credentialsManager != null);

  /// Returns information about currently logged in user
  Future<User> getUserDetails() async {
    final credentials = _credentialsManager.getCredentials();
    if (credentials == null) throw UnauthorizedException();

    final response = await _apiServer.getData(
      credentials,
      ServerRequest.get(_kUsers),
    );

    if (response.isOk) {
      return User(
          name: response.body['name'],
          hasModerationRights: response.body['hasModerationRights']);
    }

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    throw ApiException(response.error.toString());
  }
}
