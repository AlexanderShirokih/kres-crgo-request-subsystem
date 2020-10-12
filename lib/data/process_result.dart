class RequestsProcessResult<T> {
  final T data;
  final String error;
  final String stackTrace;

  const RequestsProcessResult({
    this.data,
    this.error,
    this.stackTrace,
  });

  static RequestsProcessResult<T> fromJson<T>(
          Map<String, dynamic> json, T Function(dynamic) resultBuilder) =>
      RequestsProcessResult(
        data: json['data'] != null ? resultBuilder(json['data']) : null,
        error: json['error'],
        stackTrace: json['stackTrace'],
      );

  bool hasError() => error != null && error.isNotEmpty;

  RequestsProcessException createException() => RequestsProcessException(
        error,
        stackTrace,
      );
}

class RequestsProcessException implements Exception {
  final String error;
  final String stackTrace;

  const RequestsProcessException(this.error, this.stackTrace);

  @override
  String toString() => error;
}
