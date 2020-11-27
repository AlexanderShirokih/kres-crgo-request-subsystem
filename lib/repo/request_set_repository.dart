import 'package:intl/intl.dart';
import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/models/request_set.dart';

import 'api_repository.dart';

/// Fetches information about requests set
class RequestsSetRepository with ApiRepositoryMixin {
  static const String _kRequestSet = "requests";
  static const String _kRequestSetAll = "$_kRequestSet/all";
  static const String _kPage = "page";
  static const String _kSize = "size";

  static const int _kDefaultPageSize = 5;

  final ApiServer _apiServer;

  RequestsSetWrapper _currentRequestsSets;

  RequestsSetRepository(this._apiServer) : assert(_apiServer != null);

  /// Creates new request set
  /// Updates data if ID is not `null`
  Future<RequestSet> createOrUpdateRequestSet(
    String name,
    DateTime targetDate, [
    int id,
  ]) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final response = await _apiServer.getData(
      ServerRequest.post(_kRequestSet, body: {
        'name': name,
        'date': dateFormat.format(targetDate),
        if (id != null) 'id': id
      }),
    );

    return getResponseData(response, (body) => RequestSet.fromJson(body));
  }

  /// Fetches information about requests sets from 0 to page
  Future<RequestsSetWrapper> getRequestSets(int pageUntil) async {
    final response = await _apiServer.getData(
      ServerRequest.get(
        _kRequestSet,
        requestParams: {
          _kPage: pageUntil,
          _kSize: _kDefaultPageSize,
        },
      ),
    );

    final requests = getResponseData(
      response,
      (data) => RequestsSetWrapper(
        requestsSets: [
          if (_currentRequestsSets != null)
            ..._currentRequestsSets.requestsSets,
          ...(data['content'] as List<dynamic>)
              .map((e) => RequestSet.fromJson(e))
              .toList()
        ].toSet().toList(),
        upperBoundPage: data['number'],
        hasMore: !data['last'],
      ),
    );

    _currentRequestsSets = requests;
    return requests;
  }

  /// Fetches all request sets
  Future<List<RequestSet>> getAllRequestSets() async {
    final response = await _apiServer.getData(
      ServerRequest.get(_kRequestSetAll),
    );

    return getResponseData(
      response,
      (body) =>
          (body as List<dynamic>).map((e) => RequestSet.fromJson(e)).toList(),
    );
  }

  Future<RequestSet> getRequestSetById(int id) async {
    final response = await _apiServer.getData(
      ServerRequest.get("$_kRequestSet/id"),
    );

    return getResponseData(
      response,
      (body) => RequestSet.fromJson(body),
    );
  }

  /// Fetches all request sets by `date`
  /// If `full` is `false` only id, date, name fields on `RequestSet` will be
  /// set.
  Future<List<RequestSet>> getAllRequestSetsByDate(
      DateTime date, bool full) async {
    final response = await _apiServer.getData(
      ServerRequest.get(
        _kRequestSetAll,
        requestParams: {
          "date": DateFormat('yyyy-MM-dd').format(date).toString(),
          "full": full,
        },
      ),
    );

    return getResponseData(
      response,
      (body) => (body as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((e) => RequestSet.fromJson(e))
          .toList(),
    );
  }
}
