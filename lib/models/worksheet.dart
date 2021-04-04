import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/models/request_entity.dart';

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

  /// A list of the members employee.
  final List<Employee> membersEmployee;

  /// All requests related with the worksheet
  final List<RequestEntity> requests;

  /// The worksheet targeting date
  final DateTime? targetDate;

  /// Chosen worksheets work types
  final Set<String> workTypes;

  const Worksheet({
    Set<String>? workTypes,
    required this.worksheetId,
    required this.name,
    required this.requests,
    this.targetDate,
    this.mainEmployee,
    this.chiefEmployee,
    this.membersEmployee = const [],
  }) : this.workTypes = workTypes == null ? const {} : workTypes;

  /// Returns `true` if worksheet list is empty
  bool get isEmpty => requests.isEmpty;

  /// Creates new worksheet with pushed default work types (Based on requests)
  void insertDefaultWorkTypes() {
    workTypes.addAll(
      requests
          .where((e) => e.requestType != null)
          .map((e) => e.requestType!.fullName)
          .cast<String>(),
    );
  }

  /// Converts [Worksheet] to JSON representation
  /// TODO: Create new code
  Map<String, dynamic> toJson() => throw UnimplementedError();

  // {
  //   'name': name,
  //   'mainEmployee': mainEmployee?.toMap(),
  //   'chiefEmployee': chiefEmployee?.toMap(),
  //   'membersEmployee': membersEmployee
  //       .where((e) => e != null)
  //       .map((e) => e.toMap())
  //       .toList(),
  //   'date': date?.millisecondsSinceEpoch,
  //   'requests': requests.map((r) => r.toJson()).toList(),
  //   'workTypes': workTypes.toList(),
  // };

  /// Creates a copy with customizing any parameters
  Worksheet copy({
    int? worksheetId,
    String? name,
    Set<String>? workTypes,
    List<RequestEntity>? requests,
    DateTime? targetDate,
    Employee? mainEmployee,
    Employee? chiefEmployee,
    List<Employee>? membersEmployee,
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
