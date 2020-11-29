import 'package:kres_requests2/domain/request_set_validator.dart';
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
  Future<bool> setDate(DateTime newDate) {
    // TODO:
    return Future.value(false);
  }

  /// Returns set of unique request types used in this worksheet
  Set<RequestType> getRequestTypes() =>
      _requestSet.requests.map((e) => e.requestType).toSet();

  /// Returns list of all requests
  List<Request> getRequests() => List.unmodifiable(_requestSet.requests);

  /// Swaps requests in list
  /// TODO: Pooled task
  void swap(Request toRemove, Request toInsertAfter) {
    // final idx = allRequests.indexOf(toInsertAfter);
    // allRequests.remove(toRemove);
    // allRequests.insert(idx, toRemove);
  }

  /// Updates `old` request with `edited` values
  /// TODO: Pooled task
  void update(Request old, Request edited) {
    // final oldIdx = allRequests.indexOf(old);
    // allRequests[oldIdx] = edited;
  }

  /// Removes all requests in the selection list
  /// TODO : Pooled task
  void remove(Set<Request> selectionList) {
    // for (final selected in _selectionList)
    //   _worksheet.requests.remove(selected);
  }

  /// Returns underlying `RequestSet`
  RequestSet getRequestSet() => _requestSet;

  /// Returns request set name
  String getName() => _requestSet.name;

  /// Sets request set name
  /// TODO : Pooled task
  void setName(String text) {}

  RequestSetValidator validator() => RequestSetValidator(_requestSet);
}
