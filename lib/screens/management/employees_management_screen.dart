import 'package:flutter/material.dart';
import 'package:kres_requests2/models/employee.dart';

import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/management/base_management_screen.dart';
import 'package:kres_requests2/screens/management/employees_editor_dialog.dart';
import 'package:kres_requests2/screens/management/management_editor_dialog.dart';

class EmployeesManagementScreen extends BaseManagementScreen<Employee> {
  final RepositoryModule repositoryModule;

  EmployeesManagementScreen(this.repositoryModule)
      : assert(repositoryModule != null),
        super(
          repository: repositoryModule.getEmployeesRepository(),
          typeEncoder: Employee.encoder(),
          title: 'Сотрудники',
        );

  @override
  DataRow buildRow(
    Employee e, {
    @required bool isSelected,
    @required VoidCallback onTap,
  }) =>
      DataRow(
        selected: isSelected,
        cells: [
          DataCell(
            e.status != EmployeeStatus.FIRED
                ? Text(e.name)
                : Builder(
                    builder: (context) => Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(e.name),
                        const SizedBox(width: 4.0),
                        Text(
                          '(уволен)',
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    ),
                  ),
            onTap: onTap,
          ),
          DataCell(
            Text(e.position.name),
            onTap: onTap,
          ),
          DataCell(
            Text(e.accessGroup.toString()),
            onTap: onTap,
          )
        ],
      );

  @override
  List<DataColumn> buildColumns() => [
        DataColumn(label: Text('ФИО')),
        DataColumn(label: Text('Должность')),
        DataColumn(label: Text('Группа допуска')),
      ];

  @override
  Widget createEditorDialog(Employee entity) => EmployeeEditorDialog(
        entity,
        repositoryModule.getPositionsRepository(),
      );

  @override
  List<EditableField> buildEditableFields(Employee e) => null;
}
