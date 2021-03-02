import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/repository/employee_repository.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/screens/copyable_textformfield.dart';

class WorksheetConfigView extends StatefulWidget {
  final EmployeeRepository employeeRepository;
  final Worksheet worksheet;

  const WorksheetConfigView(this.employeeRepository, this.worksheet);

  @override
  State createState() => _WorksheetConfigViewState();
}

class _Employees {
  final List<Employee> allEmployees;
  final List<Employee> chiefEmployees;

  _Employees(this.allEmployees, this.chiefEmployees);
}

class _WorksheetConfigViewState extends State<WorksheetConfigView> {
  @override
  Widget build(BuildContext context) {
    final w = widget.worksheet;
    final repo = widget.employeeRepository;

    Future<_Employees> _getEmployees() async => _Employees(
          await _getAllEmployees(repo),
          await _getAllEmployees(repo, 4),
        );

    return FutureBuilder<_Employees>(
      future: _getEmployees(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return SizedBox(
            width: 12.0,
            height: 12.0,
            child: CircularProgressIndicator(),
          );
        }
        return Form(
          child: Builder(
            builder: (ctx) => Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._header(8.0, "Выдающий распоряжение:"),
                    const SizedBox(height: 18.0),
                    _createDropdownEmployeeForm(
                      positionDesc: "Выберите выдающего распоряжения",
                      current: w.chiefEmployee,
                      employees: snap.requireData.chiefEmployees,
                      onChanged: (Employee value) => setState(() {
                        w.chiefEmployee = value;
                      }),
                    ),
                    const SizedBox(height: 28.0),
                    ..._showMainEmployee(snap.requireData.allEmployees, w),
                    const SizedBox(height: 24.0),
                    ..._showTeamMembers(ctx, snap.requireData.allEmployees, w),
                    const SizedBox(height: 24.0),
                    _DatePicker(w),
                    const SizedBox(height: 28.0),
                    ..._showWorkTypes(w),
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
      List<Employee> chiefEmployees, Worksheet w) sync* {
    yield* _header(4.0, "Производитель работ:");
    yield const SizedBox(height: 4.0);
    yield _createDropdownEmployeeForm(
      positionDesc: "Выберите производителя работ",
      current: w.mainEmployee,
      employees: chiefEmployees,
      onChanged: (Employee value) => setState(() {
        w.mainEmployee = value;
      }),
    );
  }

  Iterable<Widget> _showTeamMembers(
      BuildContext context, List<Employee> allEmployees, Worksheet w) sync* {
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
    yield* _spreadTeamMembers(
      allEmployees,
      w.membersEmployee,
    );
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
          List<Employee> employees, List<Employee> teamMembers) =>
      Iterable.generate(
        teamMembers.length,
        (i) => Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: _createDropdownEmployeeForm(
            positionDesc: "Выберите члена бригады",
            current: teamMembers[i],
            employees: employees,
            onChanged: (value) => setState(() {
              teamMembers[i] = value;
            }),
            onRemove: () => setState(() => teamMembers.removeAt(i)),
          ),
        ),
      );

  /// Returns a list of all employees, including all currently present
  /// (even if they is not present if [EmployeeRepository],
  /// but exists in [Worksheet] data)
  Future<List<Employee>> _getAllEmployees(EmployeeRepository repo,
      [int minGroup]) async {
    final w = widget.worksheet;
    final used = w.getUsedEmployee();
    final all =
        minGroup == null ? repo.getAll() : repo.getAllByMinGroup(minGroup);

    return [...used, ...await all].toSet().toList(growable: false);
  }

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
            child: DropdownButtonFormField<Employee>(
              autovalidateMode: AutovalidateMode.always,
              value: current,
              validator: (value) {
                return value == null || value.name.isEmpty
                    ? positionDesc
                    : (widget.worksheet.isUsedElseWhere(value)
                        ? 'Значение дублируется'
                        : null);
              },
              items: employees
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: e == null
                          ? Text('')
                          : Text(
                              "${e.name}, ${e.position}, ${e.accessGroup} гр."),
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
                  : CopyableTextField(
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
