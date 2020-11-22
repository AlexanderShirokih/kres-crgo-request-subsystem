import 'package:flutter/material.dart';

/// Describes main HTTP methods
enum RequestMethod { GET, POST, DELETE, PUT }

typedef BodyEncoder = T Function<S, T>(S);

/// Wrapper class for server request
class ServerRequest {
  /// HTTP request method
  final RequestMethod method;

  /// Request URL path. Should be relative to server host
  final String requestPath;

  /// Request body. Currently supporting only text bodies.
  /// Should be `null` for `GET` and `DELETE` methods.
  /// For other methods `null`  body is also acceptable and means an empty body.
  final Map<String, dynamic> body;

  final Map<String, dynamic> requestParams;

  const ServerRequest({
    @required this.method,
    @required this.requestPath,
    this.requestParams,
    this.body,
  })  : assert(method != null),
        assert(requestPath != null);

  /// Constructs GET server request at `requestPath`
  ServerRequest.get(String requestPath, {Map<String, dynamic> requestParams})
      : this(
          method: RequestMethod.GET,
          requestPath: requestPath,
          requestParams: requestParams,
        );
}
