import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/models/connection_point.dart';
import 'package:kres_requests2/domain/models/counter_info.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/domain/models/worksheets_list.dart';
import 'package:rxdart/rxdart.dart';

/// Used internally to safely update worksheet fields without side effects
class _TemporaryWorksheet {
  /// Internal worksheet ID. Should be unique for document.
  final int worksheetId;

  /// Worksheet name
  String name;

  /// The main employee. `null` if unset
  Employee? mainEmployee;

  /// The chief employee. `null` if unset
  Employee? chiefEmployee;

  /// A set of the members employee.
  Set<Employee> membersEmployee;

  /// All requests related with the worksheet
  List<RequestEntity> requests;

  /// The worksheet targeting date
  DateTime? targetDate;

  /// Chosen worksheets work types
  Set<String> workTypes;

  _TemporaryWorksheet(Worksheet original)
      : worksheetId = original.worksheetId,
        name = original.name,
        targetDate = original.targetDate,
        workTypes = Set.of(original.workTypes),
        mainEmployee = original.mainEmployee,
        chiefEmployee = original.chiefEmployee,
        membersEmployee = Set.of(original.membersEmployee),
        requests = List.of(original.requests);

  /// Returns new instance of [Worksheet]
  Worksheet toWorksheet() => Worksheet(
        worksheetId: worksheetId,
        name: name,
        requests: List.unmodifiable(requests),
        membersEmployee: Set.unmodifiable(membersEmployee),
        mainEmployee: mainEmployee,
        chiefEmployee: chiefEmployee,
        workTypes: workTypes,
        targetDate: targetDate,
      );
}

/// Controls editing of worksheet properties
class WorksheetEditor {
  final WorksheetChangeListener _onChangeListener;

  Worksheet initialWorksheet;
  _TemporaryWorksheet _current;

  WorksheetEditor(this.initialWorksheet, this._onChangeListener)
      : _current = _TemporaryWorksheet(initialWorksheet),
        _currentState = BehaviorSubject.seeded(initialWorksheet);

  /// Returns current worksheet snapshot
  Worksheet get current => _current.toWorksheet();

  final BehaviorSubject<Worksheet> _currentState;

  /// Returns stream that emits changes when editor makes commit
  Stream<Worksheet> get stream => _currentState;

  /// Returns worksheet id of associated worksheet
  int get worksheetId => initialWorksheet.worksheetId;

  // Notifies upstream list about changes.
  void commit() {
    final newWorksheet = _current.toWorksheet();

    if (newWorksheet != initialWorksheet) {
      _onChangeListener.onWorksheetChanged(initialWorksheet, newWorksheet);
      _currentState.add(newWorksheet);

      _current = _TemporaryWorksheet(newWorksheet);
      initialWorksheet = newWorksheet;
    }
  }

  /// Swaps request positions in the worksheet
  /// Both requests should already be present in the worksheet
  WorksheetEditor swapRequests(RequestEntity from, RequestEntity to) {
    if (from != to) {
      final requests = _current.requests;
      final idx = requests.indexOf(to);
      requests.remove(from);
      requests.insert(idx, from);
    }

    return this;
  }

  /// Updates current worksheet name
  WorksheetEditor setName(String text) {
    _current.name = text;
    return this;
  }

  /// Updates currently existing request
  WorksheetEditor update(RequestEntity entity) {
    final persisted = entity as PersistedObject;

    final oldEntityId = _current.requests
        .cast<PersistedObject>()
        .indexWhere((request) => request.id == persisted.id);

    if (oldEntityId == -1) {
      throw 'Request with ID: ${persisted.id} is not found in the worksheet';
    }

    _current.requests[oldEntityId] = entity;
    return this;
  }

  /// Removes requests from the worksheet
  WorksheetEditor removeRequests(List<RequestEntity> requests) {
    final currentRequests = _current.requests;

    for (final toRemove in requests) {
      currentRequests.remove(toRemove);
    }
    return this;
  }

  /// Adds all requests to the worksheet
  WorksheetEditor addAll(List<RequestEntity> requests) {
    _current.requests.addAll(requests);
    _current.workTypes = _current.workTypes.union(
      _getDefaultWorkTypes(),
    );
    return this;
  }

  /// Creates new empty request
  WorksheetEditor addRequest({
    int? accountId,
    String? name,
    String? reason,
    String? address,
    CounterInfo? counter,
    ConnectionPoint? connectionPoint,
    String? phoneNumber,
    String? additionalInfo,
    RequestType? requestType,
  }) {
    final request = initialWorksheet.createRequestEntity(
      name: name,
      reason: reason,
      address: address,
      counter: counter,
      accountId: accountId,
      phoneNumber: phoneNumber,
      requestType: requestType,
      additionalInfo: additionalInfo,
      connectionPoint: connectionPoint,
    );
    _current.requests.add(request);
    return this;
  }

  /// Updates main employee assignment in the worksheet
  WorksheetEditor setMainEmployee(Employee? employee) {
    _current.mainEmployee = employee;
    return this;
  }

  /// Updates chief employee assignment in the worksheet
  WorksheetEditor setChiefEmployee(Employee? employee) {
    _current.chiefEmployee = employee;
    return this;
  }

  /// Updates worksheet targeting date
  WorksheetEditor setTargetDate(DateTime targetDate) {
    _current.targetDate = targetDate;
    return this;
  }

  /// Updates team members list
  WorksheetEditor setTeamMembers(Set<Employee> employee) {
    _current.membersEmployee = employee;
    return this;
  }

  /// Updates work types on worksheet. Note work types got from requests can't
  /// be removed and always holds on the list. So passing empty set to this method
  /// will reset to request's types.
  WorksheetEditor setWorkTypes(Set<String> workTypes) {
    _current.workTypes = _current.workTypes.union(_getDefaultWorkTypes());
    return this;
  }

  Set<String> _getDefaultWorkTypes() {
    return _current.requests
        .where((r) => r.requestType != null)
        .map((r) => r.requestType!.fullName)
        .toSet();
  }
}
