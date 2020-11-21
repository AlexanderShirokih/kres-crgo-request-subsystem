import 'package:kres_requests2/data/models/server_error_model.dart';

/// Wrapper for server response
class ServerResponse {
  /// Server status code
  final int statusCode;

  /// Server error, if happens. So it may be `null`
  final ServerError error;

  /// Contains decoded response, if there is no error.
  final Map<String, dynamic> body;

  const ServerResponse(this.statusCode, this.error, this.body);

  /// Returns `true` is response contains errors
  bool get hasErrors => !isOk;

  /// Returns `true` is response does not contains errors
  bool get isOk => statusCode == 200 && error == null;
}
