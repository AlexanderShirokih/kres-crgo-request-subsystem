import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/models/request_set.dart';
import 'package:kres_requests2/repo/server_exception.dart';

/// Fetches information about requests set
class RequestsSetRepository {
  static const String _kRequestSet = "requests";
  static const String _kPage = "page";
  static const String _kSize = "size";
  static const int _kDefaultPageSize = 5;

  final ApiServer _apiServer;
  final CredentialsManager _credentialsManager;

  RequestsSetWrapper _currentRequestsSets;

  RequestsSetRepository(this._apiServer, this._credentialsManager)
      : assert(_apiServer != null),
        assert(_credentialsManager != null);

  /// Fetches information about requests sets from 0 to page
  Future<RequestsSetWrapper> getRequestSets(int pageUntil) async {
    final credentials = _credentialsManager.getCredentials();

    final response = await _apiServer.getData(
      credentials,
      ServerRequest.get(
        _kRequestSet,
        requestParams: {
          _kPage: pageUntil,
          _kSize: _kDefaultPageSize,
        },
      ),
    );

    if (response.isOk) {
      final data = response.body;

      final requests = RequestsSetWrapper(
        requestsSets: [
          if (_currentRequestsSets != null)
            ..._currentRequestsSets.requestsSets,
          ...(data['content'] as List<dynamic>)
              .map((e) => _makeRequestSetFromJson(e))
              .toList()
        ].toSet().toList(),
        upperBoundPage: data['number'],
        hasMore: !data['last'],
      );
      _currentRequestsSets = requests;

      return requests;
    }

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    }

    throw ApiException(response.error.toString());
  }

  RequestSet _makeRequestSetFromJson(Map<String, dynamic> data) {
    return RequestSet(
      id: data['id'],
      name: data['name'],
      date: DateTime.parse(data['date']),
    );
  }
}
