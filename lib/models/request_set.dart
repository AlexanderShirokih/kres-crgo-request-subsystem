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

  final List<Employee> assignedEmployees;

  RequestSet({
    this.id,
    this.name,
    this.date,
    this.requests,
    this.assignedEmployees,
  });
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
