import 'package:kres_requests2/data/models/credentials.dart';

/// Manages authentication credentials
abstract class CredentialsManager {
  /// Returns current credentials
  Credentials getCredentials();

  /// Sets current credentials. `credentials` should not be `null`.
  void setCredentials(Credentials credentials);
}

class CredentialsManagerImpl implements CredentialsManager {
  Credentials _currentCredentials;

  /// Returns current credentials
  Credentials getCredentials() {
    return _currentCredentials;
  }

  /// Sets current credentials. `credentials` should not be `null`.
  void setCredentials(Credentials credentials) {
    if (credentials == null) throw ('Credentials cannot be null!');

    _currentCredentials = credentials;
  }
}
