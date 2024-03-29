import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/domain/utils.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_bloc.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_events.dart';
import 'package:kres_requests2/presentation/bloc/settings/employees/employee_bloc.dart';
import 'package:kres_requests2/presentation/common/table_view.dart';
import 'package:kres_requests2/presentation/settings/common/undoable_editor_screen.dart';
import 'package:kres_requests2/presentation/settings/common/widgets/delete_button.dart';
import 'package:kres_requests2/presentation/settings/common/widgets/editable_name_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages employees.
class EmployeesScreen extends StatelessWidget
    implements TableRowBuilder<EmployeeData> {
  const EmployeesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      UndoableEditorScreen<EmployeeData, Employee>(
        blocBuilder: (_) => EmployeeBloc(
          Modular.get(),
          Modular.get(),
          Modular.get(),
        ),
        addItemButtonName: 'Добавить сотрудника',
        addItemIcon: const FaIcon(FontAwesomeIcons.userPlus),
        tableHeader: const [
          TableHeadingColumn(label: Text('ФИО'), preferredWidth: 320.0),
          TableHeadingColumn(label: Text('Должность'), preferredWidth: 168.0),
          TableHeadingColumn(
              label: Text('Группа допуска'), preferredWidth: 168.0),
          TableHeadingColumn(label: SizedBox(), preferredWidth: 60.0),
        ],
        dataRowBuilder: this,
      );

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
          items: {...data.availablePositions, e.position}
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
        padding: const EdgeInsets.only(left: 20.0),
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

  @override
  List<TableDataRow> buildDataRow(
      BuildContext context, EmployeeData dataHolder) {
    final bloc = context.read<UndoableBloc<EmployeeData, Employee>>();
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
}
