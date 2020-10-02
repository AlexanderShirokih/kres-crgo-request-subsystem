import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/employee.dart';
import 'package:kres_requests2/data/worksheet.dart';
import 'package:kres_requests2/repo/employees_repository.dart';
import 'package:intl/intl.dart';

class WorksheetConfigView extends StatefulWidget {
  final Worksheet worksheet;

  const WorksheetConfigView(this.worksheet);

  @override
  State createState() => _WorksheetConfigViewState();
}

class _WorksheetConfigViewState extends State<WorksheetConfigView> {
  @override
  Widget build(BuildContext context) {
    final w = widget.worksheet;
    return RepositoryProvider.value(
      value: EmployeesRepository(),
      child: Form(
        child: Builder(
          builder: (ctx) => Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._showMainEmployee(
                    w,
                    ctx.repository<EmployeesRepository>(),
                  ),
                  const SizedBox(height: 24.0),
                  ..._showTeamMembers(w, ctx.repository<EmployeesRepository>()),
                  ..._header(28.0, "Выдающий распоряжение:"),
                  const SizedBox(height: 18.0),
                  _createDropdownEmployeeForm(
                    positionDesc: "Выберите выдающего распоряжения",
                    current: w.mainEmployee,
                    employees: ctx
                        .repository<EmployeesRepository>()
                        .getAllByMinGroup(4),
                    onChanged: (Employee value) => setState(() {
                      w.mainEmployee = value;
                    }),
                  ),
                  const SizedBox(height: 28.0),
                  _DatePicker(w),
                  const SizedBox(height: 28.0),
                  ..._showWorkTypes(w),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Iterable<Widget> _showMainEmployee(
      Worksheet w, EmployeesRepository repo) sync* {
    yield* _header(4.0, "Производитель работ:");
    yield const SizedBox(height: 4.0);
    yield _createDropdownEmployeeForm(
      positionDesc: "Выберите производителя работ",
      current: w.mainEmployee,
      employees: repo.getAllEmployees(),
      onChanged: (Employee value) => setState(() {
        w.mainEmployee = value;
      }),
    );
  }

  Iterable<Widget> _showTeamMembers(
      Worksheet w, EmployeesRepository repo) sync* {
    yield Row(
      children: [
        Expanded(
          child: Text(
            "Члены бригады:",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.plus),
          tooltip: "Добавить члена бригады",
          onPressed: w.membersEmployee.length < 6
              ? () => setState(() {
                    w.membersEmployee.add(null);
                  })
              : null,
        ),
        const SizedBox(width: 8.0),
      ],
    );
    yield const SizedBox(height: 4.0);
    yield* _spreadTeamMembers(repo, w.membersEmployee);
  }

  Iterable<Widget> _header(double height, String text) sync* {
    yield SizedBox(height: height);
    yield Text(
      text,
      style: Theme.of(context).textTheme.headline6,
    );
  }

  Iterable<Widget> _showWorkTypes(Worksheet w) sync* {
    yield Row(
      children: [
        Expanded(
          child: Text(
            "Виды работ:",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.sync),
          tooltip: "Добавить из списка заявок",
          onPressed: () => setState(() => w.insertDefaultWorkTypes()),
        ),
        const SizedBox(width: 16.0),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.plus),
          tooltip: "Добавить",
          onPressed: () => setState(() => w.addEmptyWorkType()),
        ),
        const SizedBox(width: 8.0),
      ],
    );
    yield const SizedBox(height: 4.0);
    yield _WorkTypesList(w);
  }

  Iterable<Widget> _spreadTeamMembers(
          EmployeesRepository repo, List<Employee> teamMembers) =>
      Iterable.generate(
        teamMembers.length,
        (i) => Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: _createDropdownEmployeeForm(
            positionDesc: "Выберите члена бригады",
            current: teamMembers[i],
            employees: repo.getAllEmployees(),
            onChanged: (value) => setState(() {
              teamMembers[i] = value;
            }),
            onRemove: () => setState(() => teamMembers.removeAt(i)),
          ),
        ),
      );

  Widget _createDropdownEmployeeForm({
    String positionDesc,
    Employee current,
    List<Employee> employees,
    void Function(Employee) onChanged,
    void Function() onRemove,
  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onRemove != null)
            IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.timesCircle,
                  size: 16.0,
                ),
                onPressed: onRemove),
          Expanded(
            child: DropdownButtonFormField(
              autovalidate: true,
              value: current,
              validator: (value) => value == null ? positionDesc : null,
              items: employees
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                          "${e.name}, ${e.position}, ${e.elAccessGroup} гр."),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

class _DatePicker extends StatefulWidget {
  final Worksheet worksheet;

  const _DatePicker(this.worksheet);

  @override
  __DatePickerState createState() => __DatePickerState();
}

class __DatePickerState extends State<_DatePicker> {
  static final DateFormat _dateFormat = DateFormat("dd.MM.yyyy");
  bool _isPicking = true;

  @override
  Widget build(BuildContext context) {
    return _isPicking
        ? Row(
            children: [
              Expanded(
                child: Text(
                  "Дата выдачи задания:",
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              InkWell(
                onTap: () => setState(() {
                  _isPicking = false;
                }),
                child: FormField<DateTime>(
                  initialValue: widget.worksheet.date,
                  builder: (state) => state.hasError
                      ? Text(
                          state.errorText,
                          style: TextStyle(
                            color: Theme.of(context).errorColor,
                          ),
                        )
                      : Text(_dateFormat.format(state.value),
                          style: Theme.of(context).textTheme.subtitle1),
                  validator: (value) => value == null ? "Выберите дату" : null,
                  autovalidateMode: AutovalidateMode.always,
                ),
              ),
              const SizedBox(width: 28.0),
            ],
          )
        : CalendarDatePicker(
            initialCalendarMode: DatePickerMode.day,
            initialDate: widget.worksheet.date ?? DateTime.now(),
            firstDate: (widget.worksheet.date ?? DateTime.now())
                .subtract(Duration(days: 15)),
            lastDate: DateTime.now().add(Duration(days: 15)),
            onDateChanged: (newDate) => setState(() {
              widget.worksheet.date = newDate;
              _isPicking = true;
            }),
          );
  }
}

class _WorkTypesList extends StatefulWidget {
  final Worksheet worksheet;

  const _WorkTypesList(this.worksheet);

  @override
  __WorkTypesListState createState() => __WorkTypesListState();
}

class __WorkTypesListState extends State<_WorkTypesList> {
  @override
  Widget build(BuildContext context) {
    final worksheet = widget.worksheet;

    return Column(
      children: worksheet.workTypes
          .map(
            (e) => ListTile(
              leading: IconButton(
                icon: FaIcon(
                  FontAwesomeIcons.timesCircle,
                  size: 16.0,
                ),
                onPressed: () => setState(() => worksheet.workTypes.remove(e)),
              ),
              title: e.isNotEmpty
                  ? Text(e)
                  : TextField(
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            worksheet.workTypes.remove("");
                            worksheet.workTypes.add(value);
                          });
                        }
                      },
                    ),
            ),
          )
          .toList(),
    );
  }
}
