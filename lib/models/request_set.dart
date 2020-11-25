import 'package:flutter/cupertino.dart';
import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/models/request.dart';

/// A set of requests dated with one date
class RequestSet {
  /// Request set ID
  final int id;

  /// Request set title
  final String name;

  /// Requests target date
  final DateTime date;

  /// List of requests
  final List<Request> requests;

  final List<EmployeeAssignment> assignedEmployees;

  RequestSet({
    this.id,
    this.name,
    this.date,
    this.requests,
    this.assignedEmployees,
  });

  bool get isEmpty => requests.isEmpty;

  static RequestSet fromJson(Map<String, dynamic> data) {
    return RequestSet(
      id: data['id'],
      name: data['name'],
      date: DateTime.parse(data['date']),
      requests: data['requests'] == null
          ? null
          : (data['requests'] as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map((e) => Request.fromJson(e))
              .toList(),
      assignedEmployees: data['assignedEmployees'] == null
          ? null
          : (data['assignedEmployees'] as List<dynamic>)
              .cast<Map<String, dynamic>>()
              .map((e) => EmployeeAssignment.fromJson(e))
              .toList(),
    );
  }
}

/// Wrapper that contains meta info about fetched requests sets
class RequestsSetWrapper {
  /// `true` if source has more requests sets
  final bool hasMore;

  /// Number of page loaded until
  final int upperBoundPage;

  /// All loaded request sets
  final List<RequestSet> requestsSets;

  RequestsSetWrapper({
    @required this.hasMore,
    @required this.upperBoundPage,
    @required this.requestsSets,
  })  : assert(hasMore != null),
        assert(upperBoundPage != null),
        assert(requestsSets != null);
}
