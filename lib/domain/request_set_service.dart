import 'package:kres_requests2/domain/request_set_validator.dart';
import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/models/request.dart';
import 'package:kres_requests2/models/request_set.dart';

/// Service for editing RequestSets
class RequestSetService {
  final RequestSet _requestSet;

  const RequestSetService(this._requestSet);

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

  /// Returns list of all employees
  List<Employee> getUsedEmployee() => [
        ..._getEmployeesOfType(AssignmentType.MEMBER),
        ..._getEmployeesOfType(AssignmentType.CHIEF),
        ..._getEmployeesOfType(AssignmentType.MAIN)
      ];

  /// Returns `true` if `employee` assigned to any work
  bool isUsedElseWhere(Employee employee) =>
      getUsedEmployee().contains(employee);

  /// Sets main employee for current request set.
  /// Returns `true` if the employee was set successful.
  Future<bool> setMainEmployee(Employee newEmployee) {
    // TODO:
    return Future.value(false);
  }

  /// Sets chief employee for current request set.
  /// Returns `true` if the employee was set successful.
  Future<bool> setChiefEmployee(Employee newEmployee) {
    // TODO:
    return Future.value(false);
  }

  /// Adds empty member employee to members list
  Future<bool> addMemberEmployee() {
    // TODO:
    return Future.value(false);
  }

  /// Adds empty work type
  Future<bool> addEmptyWorkType() {
    // TODO:
    return Future.value(false);
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
