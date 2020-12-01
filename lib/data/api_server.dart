import 'dart:convert' as convert;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/data/models/server_error_model.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/repo/server_exception.dart';

import 'models/server_response.dart';

/// Bridge between client and remote server
class ApiServer {
  static const _kProtocol = 'http://';

  final http.Client _httpClient;
  final String _baseUrl;
  final CredentialsManager _credentialsManager;

  const ApiServer(
      this._httpClient, String host, int port, this._credentialsManager)
      : assert(host != null),
        assert(port != null),
        assert(_credentialsManager != null),
        _baseUrl = '$_kProtocol$host:$port/';

  Future<ServerResponse> getData(ServerRequest request) async {
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

    final credentials = _credentialsManager.getCredentials();
    if (credentials == null) throw UnauthorizedException(url);

    final headers = <String, String>{
      'Authorization': credentials.createBasicAuthorization(),
      'Content-Type': 'application/json; charset=utf-8',
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
      var jsonResponse = response.body.isEmpty
          ? <String, dynamic>{}
          : convert.jsonDecode(convert.utf8.decode(response.bodyBytes));

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        // Success
        return ServerResponse(response.statusCode, null, jsonResponse, url);
      } else if (response.statusCode == 401) {
        // Unauthorized
        return ServerResponse(
          401,
          ServerError(error: 'Unauthorized', message: ''),
          null,
          url,
        );
      } else {
        return ServerResponse(
            response.statusCode,
            ServerError(
                error:
                    jsonResponse['error'] ?? 'Response ${response.statusCode}',
                message: jsonResponse['message'] ?? 'No description attached'),
            jsonResponse,
            url);
      }
    } on convert.JsonUnsupportedObjectError catch (e) {
      return ServerResponse(
        422,
        ServerError(error: 'Json Decoding Error!', message: e.toString()),
        null,
        url,
      );
    } on SocketException catch (ex) {
      return ServerResponse(
        0,
        ServerError(
            error: '${ex.address.address}:${ex.port}',
            message: ex.osError.message),
        null,
        url,
      );
    } catch (unk) {
      return ServerResponse(
        422,
        ServerError(
            error: 'Unknown error[${unk.runtimeType}]',
            message: unk.toString()),
        null,
        url,
      );
    }
  }

  /// Closes connection to the server
  void dispose() {
    _httpClient.close();
  }

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
        return _httpClient.put(url, headers: headers, body: jsonBody);
    }
    throw ('Unknown request method!');
  }
}
