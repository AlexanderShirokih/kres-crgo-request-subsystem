import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kres_requests2/data/models/credentials.dart';
import 'package:kres_requests2/data/models/server_error_model.dart';
import 'package:kres_requests2/data/models/server_request.dart';

import 'models/server_response.dart';

/// Bridge between client and remote server
/// TODO: Should be an interface
class ApiServer {
  static const _kProtocol = 'http://';

  final http.Client _httpClient;
  final String _baseUrl;

  const ApiServer(this._httpClient, String host, int port)
      : assert(host != null),
        assert(port != null),
        _baseUrl = '$_kProtocol$host:$port/';

  Future<ServerResponse> getData(
      Credentials credentials, ServerRequest request) async {
    final requestParams = request.requestParams ?? <String, dynamic>{};

    final baseUrl = '$_baseUrl${request.requestPath}';

    // Encode path params
    StringBuffer params = StringBuffer();
    final paramEntries = requestParams.entries;
    var cnt = 0;
    for (final param in paramEntries) {
      params.write(param.key);
      params.write('=');
      params.write(param.value.toString());
      if (++cnt != requestParams.length) params.write('&');
    }

    final url = requestParams.isEmpty ? baseUrl : '$baseUrl?$params';

    final headers = <String, String>{
      "Authorization": credentials.createBasicAuthorization()
    };

    final encodedBody =
        request.body == null ? null : convert.jsonEncode(request.body);

    try {
      final response = await _doNetworkCall(
        url,
        headers,
        request.method,
        encodedBody,
      );

      var jsonResponse =
          response.body.isEmpty ? "" : convert.jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Success
        return ServerResponse(response.statusCode, null, jsonResponse);
      } else if (response.statusCode == 401) {
        // Unauthorized
        return ServerResponse(
          401,
          ServerError(error: 'Unauthorized', message: ''),
          null,
        );
      } else {
        return ServerResponse(
            response.statusCode,
            ServerError(
                error:
                    jsonResponse['error'] ?? 'Response ${response.statusCode}',
                message: jsonResponse['message'] ?? 'No description attached'),
            jsonResponse);
      }
    } on convert.JsonUnsupportedObjectError catch (e) {
      return ServerResponse(
          422,
          ServerError(error: 'Json Decoding Error!', message: e.toString()),
          null);
    } on SocketException catch (ex) {
      return ServerResponse(
          0,
          ServerError(
              error: '${ex.address.address}:${ex.port}',
              message: ex.osError.message),
          null);
    } catch (unk) {
      return ServerResponse(422,
          ServerError(error: 'Unknown error', message: unk.toString()), null);
    }
  }

  /// Closes connection to the server
  void dispose() {
    _httpClient.close();
  }

  /// TODO: Get ready to accept multipart forms
  Future<http.Response> _doNetworkCall(String url, Map<String, String> headers,
      RequestMethod method, String jsonBody) {
    switch (method) {
      case RequestMethod.GET:
        return _httpClient.get(url, headers: headers);
      case RequestMethod.DELETE:
        return _httpClient.delete(url, headers: headers);
      case RequestMethod.POST:
        return _httpClient.post(url, headers: headers, body: jsonBody);
      case RequestMethod.PUT:
        return _httpClient.post(url, headers: headers, body: jsonBody);
    }
    throw ('Unknown request method!');
  }
}
