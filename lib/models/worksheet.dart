import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// Contains info about single working document
class Worksheet {
  /// Worksheet name
  String? name;

  /// Производитель работ
  Employee? mainEmployee;

  /// Выдающий распоряжение
  Employee? chiefEmployee;

  /// Члены бригады
  List<Employee>? membersEmployee = [];

  /// Список заявок
  List<RequestEntity>? requests;

  /// Дата выдачи
  DateTime? date;

  /// Выбранные виды работ
  Set<String>? workTypes = {};

  Worksheet.withRequest({
    required this.name,
    List<RequestEntity>? requests,
  }) {
    this.requests = requests == null ? [] : requests;
  }

  Worksheet({
    this.name,
    this.mainEmployee,
    this.chiefEmployee,
    this.membersEmployee,
    this.workTypes,
    this.requests,
    this.date,
  });

  bool get isEmpty => requests?.isEmpty ?? true;

  void insertDefaultWorkTypes() {
    workTypes!.addAll(
      requests!
          .where((e) => e.requestType != null)
          .map((e) => e.requestType!.fullName)
          .cast<String>(),
    );
  }

  void addEmptyWorkType() => workTypes!.add("");

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

  Worksheet copy({String? name}) => Worksheet(
        name: name ?? this.name,
        workTypes: this.workTypes,
        requests: this.requests,
        mainEmployee: this.mainEmployee,
        chiefEmployee: this.chiefEmployee,
        membersEmployee: this.membersEmployee,
        date: this.date,
      );

  List<Employee> getUsedEmployee() =>
      [mainEmployee!, chiefEmployee!, ...membersEmployee!];

  /// Returns `true` if [employee] used more than once at any positions
  bool isUsedElseWhere(Employee employee) =>
      getUsedEmployee()
          .fold(0, (acc, e) => acc = (acc as int) + (e == employee ? 1 : 0)) >
      1;

  Iterable<String> validate() sync* {
    if (chiefEmployee == null) yield "Не выбран выдающий задание";

    if (mainEmployee == null) yield "Не выбран производитель работ";

    if (membersEmployee!.any((emp) => emp == null))
      yield "Поле члена бригады пусто";

    if (requests!.isEmpty) yield "Нет заявок для печати";

    if (requests!.length > 18)
      yield "Слишком много заявок для печати на одном листе";

    if (date == null) yield "Не выбрана дата";
  }

  bool hasErrors() => validate().iterator.moveNext();
}
