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
  final dynamic body;

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

  /// Constructs DELETE server request at `requestPath`
  ServerRequest.delete(String requestPath, {Map<String, dynamic> requestParams})
      : this(
          method: RequestMethod.DELETE,
          requestPath: requestPath,
          requestParams: requestParams,
        );

  /// Constructs POST server request at `requestPath`
  ServerRequest.post(
    String requestPath, {
    dynamic body,
    Map<String, dynamic> requestParams,
  }) : this(
          method: RequestMethod.POST,
          requestPath: requestPath,
          requestParams: requestParams,
          body: body,
        );

  /// Constructs PUT server request at `requestPath`
  ServerRequest.put(
    String requestPath, {
    dynamic body,
    Map<String, dynamic> requestParams,
  }) : this(
          method: RequestMethod.PUT,
          requestPath: requestPath,
          requestParams: requestParams,
          body: body,
        );
}
