import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/screens/bloc/editor/worksheet_config_view/worksheet_config_bloc.dart';
import 'package:kres_requests2/domain/models/employee.dart';

import 'dropdown_employee_field.dart';

/// Show view for controlling team members.
/// Requires [WorksheetConfigBloc] to be injected in the widget tree
class TeamMembersGroupView extends StatefulWidget {
  /// Currently chosen employees
  final Iterable<Employee> availableEmployees;

  /// All available team members
  final Iterable<Employee> membersEmployee;

  /// Defined can 'add' button be shown or not
  final bool canHaveMoreMembers;

  final CheckForDuplicatesCallback checkForDuplicates;

  const TeamMembersGroupView({
    Key? key,
    required this.availableEmployees,
    required this.membersEmployee,
    required this.canHaveMoreMembers,
    required this.checkForDuplicates,
  }) : super(key: key);

  @override
  _TeamMembersGroupViewState createState() => _TeamMembersGroupViewState();
}

class _TeamMembersGroupViewState extends State<TeamMembersGroupView> {
  bool _hasAdditionalField = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Члены бригады:',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              tooltip: 'Добавить члена бригады',
              onPressed: widget.canHaveMoreMembers
                  ? () => setState(() {
                        _hasAdditionalField = true;
                      })
                  : null,
            ),
            const SizedBox(width: 8.0),
          ],
        ),
        const SizedBox(height: 4.0),
        ..._spreadTeamMembers(
          context,
          widget.availableEmployees,
          widget.membersEmployee,
        ),
      ],
    );
  }

  Iterable<Widget> _spreadTeamMembers(
    BuildContext context,
    Iterable<Employee> employees,
    Iterable<Employee> teamMembers,
  ) {
    final list = [...teamMembers, if (_hasAdditionalField) null];
    return Iterable.generate(
      list.length,
      (i) => Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: DropdownEmployeeField(
          key: ObjectKey(list[i]),
          current: list[i],
          employees: employees,
          positionLabel: 'Выберите члена бригады',
          checkForDuplicates: widget.checkForDuplicates,
          onChanged: (value) => setState(() {
            list[i] = value;
            if (i == list.length - 1) _hasAdditionalField = false;
            _updateMembersList(list);
          }),
          onRemove: () => setState(() {
            if ((i == list.length - 1) && _hasAdditionalField) {
              _hasAdditionalField = false;
            } else {
              list.removeAt(i);
              _updateMembersList(list);
            }
          }),
        ),
      ),
    );
  }

  void _updateMembersList(List<Employee?> members) {
    context
        .read<WorksheetConfigBloc>()
        .add(UpdateMembersEvent(members.whereType<Employee>().toSet()));
  }
}
