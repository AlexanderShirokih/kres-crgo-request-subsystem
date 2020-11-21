/// Data class that holds server error information
class ServerError {
  /// The error kind
  final String error;

  /// Error description
  final String message;

  ServerError({this.error, this.message})
      : assert(error != null),
        assert(message != null);

  @override
  String toString() => '$error: $message';
}
