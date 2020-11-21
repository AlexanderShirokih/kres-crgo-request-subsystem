import 'dart:convert';

/// Contains data for user authorization
class Credentials {
  final String login;
  final String password;

  const Credentials(this.login, this.password)
      : assert(login != null),
        assert(password != null);

  /// Creates HTTP Basic authorization hash.
  String createBasicAuthorization() {
    final rawString = "$login:$password";
    final hash = base64Encode(rawString.codeUnits);
    return 'Basic $hash';
  }
}
