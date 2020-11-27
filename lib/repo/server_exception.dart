/// Indicates unsuccessful request result
class ApiException implements Exception {
  final String message;
  final String request;

  const ApiException(this.message, this.request)
      : assert(message != null),
        assert(request != null);

  @override
  String toString() => '$ApiException: $message. Request was: "$request"';
}

/// Indicates an authorization error
class UnauthorizedException extends ApiException {
  UnauthorizedException(String request) : super('Unauthorized!', request);
}
