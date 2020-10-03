import 'package:kres_requests2/data/employee.dart';
import 'package:kres_requests2/data/request_entity.dart';
import 'package:meta/meta.dart';

/// Contains info about single working document
class Worksheet {
  /// Worksheet name
  String name;

  /// Производитель работ
  Employee mainEmployee;

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
        'membersEmployee': membersEmployee.map((e) => e.toJson()).toList(),
        'date': date?.millisecondsSinceEpoch,
        'requests': requests.map((r) => r.toJson()).toList(),
        'workTypes': workTypes.toList(),
      };

  factory Worksheet.fromJson(Map<String, dynamic> data) => Worksheet._(
        name: data['name'] as String,
        mainEmployee: data['mainEmployee'],
        membersEmployee: (data['membersEmployee'] as List<dynamic>)
            .map((e) => Employee.fromJson(e))
            .toList(),
        requests: (data['requests'] as List<dynamic>)
            .map((r) => RequestEntity.fromJson(r))
            .toList(),
        date: data['date'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(data['date']),
        workTypes: (data['workTypes'] as List<dynamic>).cast<String>().toSet(),
      );
}
