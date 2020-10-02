import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/employee.dart';
import 'package:kres_requests2/data/request_entity.dart';

/// Contains info about single working document
class Worksheet extends Equatable {
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

  Worksheet({this.name, List<RequestEntity> requests}) {
    this.requests = requests == null ? [] : requests;
  }

  bool get isEmpty => requests.isEmpty;

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        name,
        requests,
        mainEmployee,
        membersEmployee,
        date,
        workTypes,
      ];

  void insertDefaultWorkTypes() {
    workTypes.addAll(
      requests.where((e) => e.fullReqType != null).map((e) => e.fullReqType),
    );
  }

  void addEmptyWorkType() => workTypes.add("");
}
