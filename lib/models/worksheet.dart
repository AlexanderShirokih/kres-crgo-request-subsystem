import 'package:meta/meta.dart';

import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// Contains info about single working document
class Worksheet {
  /// Worksheet name
  String name;

  /// Производитель работ
  Employee mainEmployee;

  /// Выдающий распоряжение
  Employee chiefEmployee;

  /// Члены бригады
  List<Employee> membersEmployee = [];

  /// Список заявок
  List<RequestEntity> requests;

  /// Дата выдачи
  DateTime date;

  /// Выбранные виды работ
  Set<String> workTypes = {};

  Worksheet({
    @required this.name,
    List<RequestEntity> requests,
  }) {
    this.requests = requests == null ? [] : requests;
  }

  Worksheet._({
    this.name,
    this.mainEmployee,
    this.chiefEmployee,
    this.membersEmployee,
    this.workTypes,
    this.requests,
    this.date,
  });

  bool get isEmpty => requests.isEmpty;

  void insertDefaultWorkTypes() {
    workTypes.addAll(
      requests.where((e) => e.fullReqType != null).map((e) => e.fullReqType),
    );
  }

  void addEmptyWorkType() => workTypes.add("");

  /// Converts [Worksheet] to JSON representation
  Map<String, dynamic> toJson() => {
        'name': name,
        'mainEmployee': mainEmployee?.toJson(),
        'chiefEmployee': chiefEmployee?.toJson(),
        'membersEmployee': membersEmployee
            .where((e) => e != null)
            .map((e) => e.toJson())
            .toList(),
        'date': date?.millisecondsSinceEpoch,
        'requests': requests.map((r) => r.toJson()).toList(),
        'workTypes': workTypes.toList(),
      };

  factory Worksheet.fromJson(Map<String, dynamic> data) => Worksheet._(
        name: data['name'] as String,
        mainEmployee: data['mainEmployee'] == null
            ? null
            : Employee.fromJson(data['mainEmployee']),
        chiefEmployee: data['chiefEmployee'] == null
            ? null
            : Employee.fromJson(data['chiefEmployee']),
        membersEmployee: (data['membersEmployee'] as List<dynamic>)
            .map((e) => Employee.fromJson(e))
            .take(6)
            .toList(),
        requests: (data['requests'] as List<dynamic>)
            .map((r) => RequestEntity.fromJson(r))
            .toList(),
        date: data['date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(data['date']),
        workTypes: (data['workTypes'] as List<dynamic>).cast<String>().toSet(),
      );

  Worksheet copy({String name}) => Worksheet._(
        name: name ?? this.name,
        workTypes: this.workTypes,
        requests: this.requests,
        mainEmployee: this.mainEmployee,
        chiefEmployee: this.chiefEmployee,
        membersEmployee: this.membersEmployee,
        date: this.date,
      );

  List<Employee> getUsedEmployee() =>
      [mainEmployee, chiefEmployee, ...membersEmployee];

  /// Returns `true` if [employee] used more than once at any positions
  bool isUsedElseWhere(Employee employee) =>
      getUsedEmployee().fold(0, (acc, e) => acc += (e == employee ? 1 : 0)) > 1;

  Iterable<String> validate() sync* {
    if (chiefEmployee == null) yield "Не выбран выдающий задание";

    if (mainEmployee == null) yield "Не выбран производитель работ";

    if (membersEmployee.any((emp) => emp == null))
      yield "Поле члена бригады пусто";

    if (requests.isEmpty) yield "Нет заявок для печати";

    if (requests.length > 18)
      yield "Слишком много заявок для печати на одном листе";

    if (date == null) yield "Не выбрана дата";
  }

  bool hasErrors() => validate().iterator.moveNext();
}
