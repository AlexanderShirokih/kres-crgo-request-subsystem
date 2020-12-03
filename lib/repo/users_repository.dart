import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/data/models/credentials.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/models/user.dart';
import 'package:kres_requests2/repo/base_crud_repository.dart';

/// Fetches information about users
class UsersRepository extends BaseCRUDRepository<User> {
  static const _kUsers = 'users';

  final CredentialsManager _credentialsManager;

  Credentials _fetchedUserCredentials;
  User _fetchedUser;

  UsersRepository(ApiServer apiServer, this._credentialsManager)
      : super(apiServer, User.encoder(), _kUsers);

  /// Returns information about currently logged in user
  Future<User> getUserDetails() async {
    final credentials = _credentialsManager.getCredentials();
    if (_fetchedUserCredentials == credentials) {
      // Return user from cache
      return _fetchedUser;
    }

    _fetchedUser = null;
    _fetchedUserCredentials = credentials;

    final response = await apiServer.getData(
      ServerRequest.get('$_kUsers/current'),
    );

    _fetchedUser = getResponseData(
      response,
      (body) => User.encoder().fromJson(body),
    );

    return _fetchedUser;
  }
}
