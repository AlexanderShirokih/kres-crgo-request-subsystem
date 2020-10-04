import 'package:kres_requests2/data/employee.dart';

class EmployeesRepository {
  List<Employee> getAllEmployees() => [
        Employee(
          name: "Широких А.В.",
          position: "эл.монт.",
          accessGroup: 3,
        ),
        Employee(
          name: "Рясная Я.В.",
          position: "эл.монт.",
          accessGroup: 3,
        ),
        Employee(
          name: "Петренко И.П.",
          position: "мастер БОП",
          accessGroup: 4,
        ),
        Employee(
          name: "Моисеенко В.В.",
          position: "инженер БОП",
          accessGroup: 5,
        ),
      ];

  List<Employee> getAllByMinGroup(int minGroup) => getAllEmployees()
      .where((element) => element.accessGroup >= minGroup)
      .toList();
}
