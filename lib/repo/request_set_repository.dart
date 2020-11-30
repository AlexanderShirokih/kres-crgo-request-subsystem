import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/models/request.dart';
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

  /// Assigns employee to the request set
  Future<void> assignEmployee(
    RequestSet r,
    Employee emp,
    AssignmentType type,
  ) async {
    assert(r != null && emp != null && type != null);
    final response = await _apiServer.getData(
      ServerRequest.post(
          'requests/${r.id}/employees/${emp.id}/${type.value()}'),
    );

    ensureOk(response);
  }

  /// Removes employee from request set
  Future<void> removeEmployee(RequestSet r, Employee emp) async {
    assert(r != null && emp != null);

    final response = await _apiServer.getData(
      ServerRequest.delete('requests/${r.id}/employees/${emp.id}'),
    );

    ensureOk(response);
  }

  /// Removes request set from the document
  Future<void> removeWorksheet(RequestSet set) async {
    final response = await _apiServer.getData(
      ServerRequest.delete('requests/worksheets/${set.id}'),
    );

    ensureOk(response);
  }

  /// Creates new request set
  /// Updates data if ID is not `null`
  Future<RequestSet> createOrUpdateRequestSet(
    String name,
    DateTime targetDate, [
    int id,
  ]) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final response = await _apiServer.getData(
      ServerRequest.post('$_kRequestSet/worksheets/', body: {
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

  /// Adds a new request to request set
  Future<Request> addRequest(RequestSet target, Request request) async {
    final requestEncoder = Request.encoder();

    final response = await _apiServer.getData(
      ServerRequest.put('$_kRequestSet/${target.id}',
          body: requestEncoder.toJson(request)),
    );

    print(json.encode(requestEncoder.toJson(request)));

    return getResponseData(response, (body) => requestEncoder.fromJson(body));
  }

  /// Updates an existing request
  Future<void> updateRequest(Request request) async {
    final requestEncoder = Request.encoder();

    final response = await _apiServer.getData(
      ServerRequest.post('$_kRequestSet/${request.id}',
          body: requestEncoder.toJson(request)),
    );

    ensureOk(response);
  }

  /// Removes request from the database
  Future<void> removeRequest(Request request) async {
    assert(request != null && request.id != null);

    final response = await _apiServer.getData(
      ServerRequest.delete('$_kRequestSet/${request.id}'),
    );

    ensureOk(response);
  }
}
