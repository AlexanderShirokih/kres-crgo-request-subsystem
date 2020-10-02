import 'package:kres_requests2/data/employee.dart';

class EmployeesRepository {
  List<Employee> getAllEmployees() => [
        Employee(
          name: "Широких А.В.",
          position: "эл.монт.",
          elAccessGroup: 3,
        ),
        Employee(
          name: "Петренко И.П.",
          position: "мастер БОП",
          elAccessGroup: 4,
        ),
        Employee(
          name: "Моисеенко В.В.",
          position: "инженер БОП",
          elAccessGroup: 5,
        ),
      ];

  List<Employee> getAllByMinGroup(int minGroup) => getAllEmployees()
      .where((element) => element.elAccessGroup >= minGroup)
      .toList();
}
