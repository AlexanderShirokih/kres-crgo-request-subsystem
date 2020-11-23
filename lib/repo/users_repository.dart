import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/data/models/credentials.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/models/user.dart';
import 'package:kres_requests2/repo/api_repository.dart';
import 'package:kres_requests2/repo/server_exception.dart';

/// Fetches information about users
class UsersRepository with ApiRepositoryMixin {
  static const _kUsers = 'users';

  final CredentialsManager _credentialsManager;
  final ApiServer _apiServer;

  Credentials _fetchedUserCredentials;
  User _fetchedUser;

  UsersRepository(this._apiServer, this._credentialsManager)
      : assert(_apiServer != null),
        assert(_credentialsManager != null);

  /// Returns information about currently logged in user
  Future<User> getUserDetails() async {
    final credentials = _credentialsManager.getCredentials();
    if (_fetchedUserCredentials == credentials) {
      // Return user from cache
      return _fetchedUser;
    }

    _fetchedUser = null;
    _fetchedUserCredentials = credentials;

    if (credentials == null) throw UnauthorizedException();

    final response = await _apiServer.getData(
      credentials,
      ServerRequest.get(_kUsers),
    );

    _fetchedUser = getResponseData(
      response,
      (body) => User(
          name: response.body['name'],
          hasModerationRights: response.body['hasModerationRights']),
    );

    return _fetchedUser;
  }
}
