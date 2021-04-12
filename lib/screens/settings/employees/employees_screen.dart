import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/validators.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/utils.dart';
import 'package:kres_requests2/screens/common/table_view.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_bloc.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_events.dart';
import 'package:kres_requests2/screens/settings/common/undoable_editor_screen.dart';
import 'package:kres_requests2/screens/settings/common/widgets/delete_button.dart';
import 'package:kres_requests2/screens/settings/common/widgets/editable_name_field.dart';
import 'package:kres_requests2/screens/settings/employees/bloc/employee_bloc.dart';

/// Manages employees.
class EmployeesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => UndoableEditorScreen(
        blocBuilder: (_) => EmployeeBloc(
          Modular.get(),
          Modular.get(),
          Modular.get(),
        ),
        addItemButtonName: 'Добавить сотрудника',
        addItemIcon: FaIcon(FontAwesomeIcons.userPlus),
        tableHeader: [
          TableHeadingColumn(label: Text('ФИО'), preferredWidth: 320.0),
          TableHeadingColumn(label: Text('Должность'), preferredWidth: 168.0),
          TableHeadingColumn(
              label: Text('Группа допуска'), preferredWidth: 168.0),
          TableHeadingColumn(label: const SizedBox(), preferredWidth: 60.0),
        ],
        dataRowBuilder: _buildData,
      );

  List<TableDataRow> _buildData(
      UndoableBloc<EmployeeData, Employee> bloc, EmployeeData dataHolder) {
    return dataHolder.data.map((e) {
      return TableDataRow(
        key: ObjectKey(e),
        cells: [
          EditableNameField(
            validator: Modular.get<MappedValidator<Employee>>()
                .findValidator<StringValidator>('name'),
            value: e.name,
            onChanged: (newValue) =>
                _fireItemChanged(bloc, e, e.copy(name: newValue)),
          ),
          _createPositionDropdown(bloc, e, dataHolder),
          _createGroupDropdown(bloc, e, dataHolder),
          DeleteButton(
            onPressed: () => bloc.add(DeleteItemEvent(e)),
          ),
        ],
      );
    }).toList();
  }

  void _fireItemChanged(UndoableBloc<EmployeeData, Employee> bloc,
          Employee source, Employee updated) =>
      bloc.add(UpdateItemEvent(source, updated));

  Widget _createPositionDropdown(UndoableBloc<EmployeeData, Employee> bloc,
          Employee e, EmployeeData data) =>
      SizedBox(
        width: 140.0,
        child: DropdownButton<Position>(
          onChanged: (newPosition) =>
              _fireItemChanged(bloc, e, e.copy(position: newPosition)),
          value: e.position,
          items: [...data.availablePositions, e.position]
              .toSet()
              .map(
                (e) => DropdownMenuItem<Position>(
                  child: Text(e.name),
                  value: e,
                ),
              )
              .toList(),
        ),
      );

  Widget _createGroupDropdown(UndoableBloc<EmployeeData, Employee> bloc,
          Employee e, EmployeeData data) =>
      Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: DropdownButton<int>(
          key: ValueKey(e),
          onChanged: (newGroup) =>
              _fireItemChanged(bloc, e, e.copy(accessGroup: newGroup)),
          value: e.accessGroup,
          items: data.groups
              .map(
                (e) => DropdownMenuItem<int>(
                  child: Text(e.romanGroup),
                  value: e,
                ),
              )
              .toList(),
        ),
      );
}
