import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/models/request_entity.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/models/counter_info.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';

import 'connection_point.dart';

/// Contains info about single working document
class Worksheet extends Equatable {
  /// Internal worksheet ID. Should be unique for document.
  final int worksheetId;

  /// Worksheet name
  final String name;

  /// The main employee. `null` if unset
  final Employee? mainEmployee;

  /// The chief employee. `null` if unset
  final Employee? chiefEmployee;

  /// A set of the members employee.
  final Set<Employee> membersEmployee;

  /// All requests related with the worksheet
  final List<RequestEntity> requests;

  /// The worksheet targeting date
  final DateTime? targetDate;

  /// Chosen worksheets work types
  final Set<String> workTypes;

  Worksheet({
    Set<String>? workTypes,
    required this.worksheetId,
    required this.name,
    required this.requests,
    this.targetDate,
    this.mainEmployee,
    this.chiefEmployee,
    this.membersEmployee = const {},
  }) : this.workTypes = workTypes == null
            ? _getDefaultWorkTypes(requests)
            : workTypes.union(_getDefaultWorkTypes(requests));

  /// Returns `true` if worksheet list is empty
  bool get isEmpty => requests.isEmpty;

  // Inserts default request types based on requests list
  static _getDefaultWorkTypes(Iterable<RequestEntity> requests) => requests
      .where((e) => e.requestType != null)
      .map((e) => e.requestType!.fullName)
      .cast<String>()
      .toSet();

  static int _lastRequestId = 0;

  // Allocates new request id
  int _nextRequestId() => ++_lastRequestId;

  /// Creates new empty request entity
  RequestEntity createRequestEntity({
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
    return RequestEntityImpl(
      id: _nextRequestId(),
      accountId: accountId,
      name: name ?? '',
      reason: reason,
      address: address ?? '',
      counter: counter,
      connectionPoint: connectionPoint,
      phoneNumber: phoneNumber,
      additionalInfo: additionalInfo,
      requestType: requestType,
    );
  }

  /// Creates a copy with customizing any parameters
  Worksheet copyWith({
    String? name,
    Set<String>? workTypes,
    List<RequestEntity>? requests,
    DateTime? targetDate,
    Employee? mainEmployee,
    Employee? chiefEmployee,
    Set<Employee>? membersEmployee,
    int? worksheetId,
  }) =>
      Worksheet(
        worksheetId: worksheetId ?? this.worksheetId,
        name: name ?? this.name,
        workTypes: workTypes ?? this.workTypes,
        requests: requests ?? this.requests,
        mainEmployee: mainEmployee ?? this.mainEmployee,
        chiefEmployee: chiefEmployee ?? this.chiefEmployee,
        membersEmployee: membersEmployee ?? this.membersEmployee,
        targetDate: targetDate ?? this.targetDate,
      );

  /// Returns a list of employees used in all positions
  List<Employee> getUsedEmployee() => [
        if (mainEmployee != null) mainEmployee!,
        if (chiefEmployee != null) chiefEmployee!,
        ...membersEmployee,
      ];

  /// Returns `true` if [employee] used more than once at any positions
  bool isUsedElseWhere(Employee employee) =>
      getUsedEmployee()
          .fold(0, (acc, e) => acc = (acc as int) + (e == employee ? 1 : 0)) >
      1;

  Iterable<String> validate() sync* {
    if (chiefEmployee == null) yield "Не выбран выдающий задание";

    if (mainEmployee == null) yield "Не выбран производитель работ";

    if (requests.isEmpty) yield "Нет заявок для печати";

    if (requests.length > 18)
      yield "Слишком много заявок для печати на одном листе";

    if (targetDate == null) yield "Не выбрана дата";
  }

  bool hasErrors() => validate().iterator.moveNext();

  @override
  List<Object?> get props => [
        name,
        worksheetId,
        requests,
        workTypes,
        targetDate,
        mainEmployee,
        chiefEmployee,
        membersEmployee,
      ];
}
