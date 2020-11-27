import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:intl/intl.dart';

import 'package:kres_requests2/domain/request_set_service.dart';
import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/repo/repository_module.dart';

class WorksheetConfigView extends StatefulWidget {
  final RequestSetService requestSetService;
  final RepositoryModule repositoryModule;

  WorksheetConfigView(this.repositoryModule, this.requestSetService);

  @override
  State createState() => _WorksheetConfigViewState();
}

class _WorksheetConfigViewState extends State<WorksheetConfigView> {
  @override
  Widget build(BuildContext context) {
    final w = widget.requestSetService;
    return FutureBuilder<List<Employee>>(
      future: widget.repositoryModule.getEmployeesRepository().getAll(),
      builder: (context, snap) {
        final employees =
            (snap.hasError || !snap.hasData) ? <Employee>[] : snap.data;

        /// Returns a list of all employees, including all currently present
        /// (even if they is not present if [EmployeesRepository],
        /// but exists in [RequestSet] data)
        List<Employee> getAllEmployees([int minGroup]) {
          final used = widget.requestSetService.getUsedEmployee();
          final all = minGroup == null
              ? employees
              : employees
                  .where((element) => element.accessGroup >= minGroup)
                  .toList();
          return [...used, ...all].toSet().toList(growable: false);
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
                      current: w.getChiefEmployee(),
                      employees: getAllEmployees(4),
                      onChanged: (Employee value) => w
                          .setChiefEmployee(value)
                          .then((isOk) => setState(() {})),
                    ),
                    const SizedBox(height: 28.0),
                    ..._showMainEmployee(employees, w),
                    const SizedBox(height: 24.0),
                    ..._showTeamMembers(employees, ctx, w),
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
      List<Employee> employees, RequestSetService w) sync* {
    yield* _header(4.0, "Производитель работ:");
    yield const SizedBox(height: 4.0);
    yield _createDropdownEmployeeForm(
      positionDesc: "Выберите производителя работ",
      current: w.getMainEmployee(),
      employees: employees,
      onChanged: (Employee value) =>
          w.setMainEmployee(value).then((isOk) => setState(() {})),
    );
  }

  Iterable<Widget> _showTeamMembers(List<Employee> employees,
      BuildContext context, RequestSetService w) sync* {
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
          onPressed: w.getMembersEmployee().length < 6
              ? () => w.addMemberEmployee().then((isOk) => setState(() {}))
              : null,
        ),
        const SizedBox(width: 8.0),
      ],
    );
    yield const SizedBox(height: 4.0);
    yield* _spreadTeamMembers(
      employees,
      w.getMembersEmployee(),
    );
  }

  Iterable<Widget> _header(double height, String text) sync* {
    yield SizedBox(height: height);
    yield Text(
      text,
      style: Theme.of(context).textTheme.headline6,
    );
  }

  Iterable<Widget> _showWorkTypes(RequestSetService w) sync* {
    yield Row(
      children: [
        Expanded(
          child: Text(
            "Виды работ:",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        IconButton(
          icon: FaIcon(FontAwesomeIcons.plus),
          tooltip: "Добавить",
          onPressed: () => w.addEmptyWorkType().then((_) => setState(() {})),
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
                    : (widget.requestSetService.isUsedElseWhere(value)
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
                              "${e.name}, ${e.position.name}, ${e.accessGroup} гр."),
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
  final RequestSetService requestSet;

  const _DatePicker(this.requestSet);

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
                  initialValue: widget.requestSet.getDate(),
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
            initialDate: widget.requestSet.getDate() ?? DateTime.now(),
            firstDate: (widget.requestSet.getDate() ?? DateTime.now())
                .subtract(Duration(days: 15)),
            lastDate: DateTime.now().add(Duration(days: 15)),
            onDateChanged: (newDate) =>
                widget.requestSet.setDate(newDate).then((isOk) {
              if (isOk) {
                setState(() {
                  _isPicking = true;
                });
              }
            }),
          );
  }
}

class _WorkTypesList extends StatefulWidget {
  final RequestSetService requestSetService;

  const _WorkTypesList(this.requestSetService);

  @override
  __WorkTypesListState createState() => __WorkTypesListState();
}

class __WorkTypesListState extends State<_WorkTypesList> {
  @override
  Widget build(BuildContext context) {
    final requestSet = widget.requestSetService;

    return Column(
      children: requestSet
          .getRequestTypes()
          .map((e) => ListTile(title: Text(e.fullName)))
          .toList(),
    );
  }
}
