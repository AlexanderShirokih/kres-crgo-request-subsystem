import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/models/request.dart';
import 'package:kres_requests2/models/request_set.dart';
import 'package:kres_requests2/repo/request_set_repository.dart';
import 'package:kres_requests2/repo/server_exception.dart';

/// Service for editing RequestSets
class RequestSetService {
  final RequestsSetRepository _repository;
  final RequestSet _requestSet;

  const RequestSetService(this._repository, this._requestSet)
      : assert(_repository != null),
        assert(_requestSet != null);

  /// Returns `true` if request set has no requests
  bool get isEmpty => _requestSet.isEmpty;

  /// Returns main employee assigned to this request set or `null`
  Employee getMainEmployee() => _getEmployeesOfType(AssignmentType.MAIN)
      .singleWhere((_) => true, orElse: () => null);

  /// Returns chief employee assigned to this request set or `null`
  Employee getChiefEmployee() => _getEmployeesOfType(AssignmentType.CHIEF)
      .singleWhere((_) => true, orElse: () => null);

  /// Returns list of members employee assigned to this request set or `null`
  List<Employee> getMembersEmployee() =>
      _getEmployeesOfType(AssignmentType.MEMBER).toList();

  Iterable<Employee> _getEmployeesOfType(AssignmentType type) =>
      _requestSet.assignedEmployees == null
          ? null
          : _requestSet.assignedEmployees
              .where((element) => element.type == type)
              .map((e) => e.employee);

  /// Returns set of all employees excluding
  Set<Employee> getUsedEmployee() => [
        ..._getEmployeesOfType(AssignmentType.MEMBER),
        ..._getEmployeesOfType(AssignmentType.CHIEF),
        ..._getEmployeesOfType(AssignmentType.MAIN)
      ].toSet();

  /// Returns `true` if `employee` assigned to any work
  bool isUsedElseWhere(Employee employee, AssignmentType wantedType) =>
      _requestSet.assignedEmployees == null
          ? null
          : _requestSet.assignedEmployees
                  .where((element) => element.type != wantedType)
                  .firstWhere((e) => e.employee == employee,
                      orElse: () => null) !=
              null;

  /// Sets main employee for current request set.
  /// Returns `true` if the employee was set successful.
  Future<bool> setMainEmployee(Employee newEmployee) =>
      _assignEmployee(newEmployee, AssignmentType.MAIN);

  /// Sets chief employee for current request set.
  /// Returns `true` if the employee was set successful.
  Future<bool> setChiefEmployee(Employee newEmployee) =>
      _assignEmployee(newEmployee, AssignmentType.CHIEF);

  /// Adds member employee to members list
  Future<bool> addMemberEmployee(Employee e) =>
      _assignEmployee(e, AssignmentType.MEMBER);

  Future<bool> _assignEmployee(
      Employee emp, AssignmentType assignmentType) async {
    try {
      await _repository.assignEmployee(_requestSet, emp, assignmentType);
      _requestSet.assignedEmployees.removeWhere((e) =>
          e.employee == emp ||
          e.type == assignmentType &&
              (e.type == AssignmentType.MAIN ||
                  e.type == AssignmentType.CHIEF));
      _requestSet.assignedEmployees.add(EmployeeAssignment(
        employee: emp,
        type: assignmentType,
      ));
      return true;
    } on ApiException {
      return false;
    }
  }

  /// Removes employee from the worksheet
  Future<bool> removeEmployee(Employee emp) async {
    try {
      await _repository.removeEmployee(_requestSet, emp);
      _requestSet.assignedEmployees
          .removeWhere((assignment) => assignment.employee == emp);
      return true;
    } on ApiException {
      return false;
    }
  }

  /// Returns target date for this worksheet
  DateTime getDate() => _requestSet.date;

  /// Sets target date for this worksheet
  Future<bool> setDate(DateTime newDate) async {
    try {
      _requestSet.date = newDate;
      await _repository.createOrUpdateRequestSet(
          _requestSet.name, newDate, _requestSet.id);
    } on ApiException {
      return false;
    }
    return true;
  }

  /// Returns set of unique request types used in this worksheet
  Set<RequestType> getRequestTypes() =>
      _requestSet.requests.map((e) => e.requestType).toSet();

  /// Returns list of all requests
  List<Request> getRequests() => List.unmodifiable(_requestSet.requests ?? []);

  /// Swaps requests in list. Currently only on the client side
  void swap(Request toRemove, Request toInsertAfter) {
    final requests = _requestSet.requests;
    final idx = requests.indexOf(toInsertAfter);
    requests.remove(toRemove);
    requests.insert(idx, toRemove);
  }

  /// Adds new request to the worksheet
  Future<bool> addRequest(Request request) async {
    assert(request.id == null);

    try {
      Request added = await _repository.addRequest(_requestSet, request);
      if (added != null) {
        _requestSet.requests.add(added);
      } else
        return false;
    } on ApiException {
      return false;
    }
    return true;
  }

  /// Updates `old` request with `edited` values
  Future<bool> update(Request old, Request edited) async {
    assert(old.id == edited.id);

    try {
      await _repository.updateRequest(edited);
      final oldIdx = _requestSet.requests.indexWhere((e) => e.id == old.id);
      _requestSet.requests[oldIdx] = edited;
    } on ApiException {
      return false;
    }

    return true;
  }

  /// Removes all requests in the selection list
  Future<bool> remove(Set<Request> selectionList) async {
    try {
      for (final request in selectionList) {
        await _repository.removeRequest(request);
        _requestSet.requests.remove(request);
      }
    } on ApiException {
      return false;
    }
    return true;
  }

  /// Returns underlying `RequestSet`
  RequestSet getRequestSet() => _requestSet;

  /// Returns request set name
  String getName() => _requestSet.name;

  /// Sets request set name. Returns `true` if renaming was successful
  Future<bool> setName(String newName) async {
    try {
      _requestSet.name = newName;
      await _repository.createOrUpdateRequestSet(
          newName, _requestSet.date, _requestSet.id);
    } on ApiException {
      return false;
    }
    return true;
  }
}
