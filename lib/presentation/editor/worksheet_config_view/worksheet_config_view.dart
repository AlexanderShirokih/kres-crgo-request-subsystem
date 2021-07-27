import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/worksheet_config_view/worksheet_config_bloc.dart';

import 'widgets/date_picker.dart';
import 'widgets/dropdown_employee_field.dart';
import 'widgets/team_members_group_view.dart';
import 'widgets/work_types_list.dart';

/// Bottom side view used to manage employees, target date, and work types.
/// Requires [WorksheetConfigBloc] to be injected in the widget tree
class WorksheetConfigView extends StatelessWidget {
  const WorksheetConfigView();

  Widget build(BuildContext context) {
    return BlocBuilder<WorksheetConfigBloc, BaseState>(
      builder: (context, state) {
        if (state is! DataState<WorksheetConfigInfo>) {
          return Center(
            child: SizedBox(
              width: 12.0,
              height: 12.0,
              child: CircularProgressIndicator(),
            ),
          );
        }

        final info = state.data;

        return Form(
          child: Builder(
            builder: (ctx) => Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._header(context, 8.0, 'Выдающий распоряжение:'),
                    const SizedBox(height: 18.0),
                    DropdownEmployeeField(
                      checkForDuplicates: info.isUsedElseWhere,
                      positionLabel: 'Выберите выдающего распоряжения',
                      current: info.chiefEmployee,
                      employees: info.chiefEmployees,
                      onChanged: (Employee? value) => ctx
                          .read<WorksheetConfigBloc>()
                          .add(UpdateSingleEmployeeEvent(
                            value,
                            SingleEmployeeType.chief,
                          )),
                    ),
                    const SizedBox(height: 28.0),
                    ..._showMainEmployee(ctx, info),
                    const SizedBox(height: 24.0),
                    TeamMembersGroupView(
                      availableEmployees: info.teamMembersEmployees,
                      membersEmployee: info.membersEmployee,
                      canHaveMoreMembers: info.canHaveMoreMembers,
                      checkForDuplicates: info.isUsedElseWhere,
                    ),
                    const SizedBox(height: 24.0),
                    DatePicker(
                      targetDate: info.targetDate,
                      key: ObjectKey(info.targetDate),
                    ),
                    const SizedBox(height: 28.0),
                    WorkTypesList(
                      workTypes: info.workTypes,
                      key: ObjectKey(info.workTypes),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Iterable<Widget> _showMainEmployee(
      BuildContext ctx, WorksheetConfigInfo info) sync* {
    yield* _header(ctx, 4.0, 'Производитель работ:');
    yield const SizedBox(height: 4.0);
    yield DropdownEmployeeField(
      checkForDuplicates: info.isUsedElseWhere,
      positionLabel: 'Выберите производителя работ',
      current: info.mainEmployee,
      employees: info.mainEmployees,
      onChanged: (Employee? value) => ctx.read<WorksheetConfigBloc>().add(
            UpdateSingleEmployeeEvent(value, SingleEmployeeType.main),
          ),
    );
  }

  Iterable<Widget> _header(
      BuildContext context, double height, String text) sync* {
    yield SizedBox(height: height);
    yield Text(
      text,
      style: Theme.of(context).textTheme.headline6,
    );
  }
}
