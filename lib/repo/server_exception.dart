/// Indicates unsuccessful request result
class ApiException implements Exception {
  final String message;

  const ApiException(this.message) : assert(message != null);

  @override
  String toString() => '$ApiException: $message';
}

/// Indicates an authorization error
class UnauthorizedException extends ApiException {
  UnauthorizedException() : super('Unauthorized!');
}
