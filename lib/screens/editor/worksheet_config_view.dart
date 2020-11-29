import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kres_requests2/bloc/worksheets/worksheet_master_bloc.dart';
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
        final employees = ((snap.hasError || !snap.hasData)
                ? Set<Employee>()
                : snap.data.toSet())
            .difference(w.getUsedEmployee());
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
                    _EmployeeSelector(
                      positionDesc: "Выберите выдающего распоряжения",
                      isUsed: (v) => w.isUsedElseWhere(v, AssignmentType.CHIEF),
                      current: w.getChiefEmployee(),
                      employees: employees.where((e) => e.accessGroup >= 4),
                      onChanged: (Employee value) => w.setChiefEmployee(value),
                    ),
                    const SizedBox(height: 28.0),
                    ..._showMainEmployee(employees, ctx, w),
                    const SizedBox(height: 24.0),
                    _MembersList(employees, w),
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

  Iterable<Widget> _showMainEmployee(Iterable<Employee> employees,
      BuildContext context, RequestSetService w) sync* {
    yield* _header(4.0, "Производитель работ:");
    yield const SizedBox(height: 4.0);
    yield _EmployeeSelector(
      positionDesc: "Выберите производителя работ",
      isUsed: (v) => w.isUsedElseWhere(v, AssignmentType.MAIN),
      current: w.getMainEmployee(),
      employees: employees,
      onChanged: (Employee value) => w.setMainEmployee(value),
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
    final requestTypes = w.getRequestTypes();
    yield Row(
      children: [
        Expanded(
          child: Text(
            "Виды работ:",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        if (requestTypes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Text('Пока ничего нет'),
          ),
      ],
    );
    yield const SizedBox(height: 4.0);
    yield Column(
        children: requestTypes
            .map((e) => ListTile(
                  leading: FaIcon(FontAwesomeIcons.wrench),
                  title: Text(e.fullName),
                ))
            .toList());
  }
}

class _MembersList extends StatefulWidget {
  final Iterable<Employee> employees;
  final RequestSetService requestSetService;

  const _MembersList(this.employees, this.requestSetService);

  @override
  State<StatefulWidget> createState() => __MembersListState();
}

class __MembersListState extends State<_MembersList> {
  bool _hasExtraField = false;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                onPressed:
                    widget.requestSetService.getMembersEmployee().length < 6
                        ? () => setState(() => _hasExtraField = true)
                        : null,
              ),
              const SizedBox(width: 8.0),
            ],
          ),
          const SizedBox(height: 4.0),
          ..._spreadTeamMembers(
            widget.employees,
            _hasExtraField
                ? [null, ...widget.requestSetService.getMembersEmployee()]
                : widget.requestSetService.getMembersEmployee(),
          ),
        ],
      );

  Iterable<Widget> _spreadTeamMembers(
          Iterable<Employee> employees, Iterable<Employee> teamMembers) =>
      teamMembers.map((teamMember) => Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: _EmployeeSelector(
              isUsed: (v) => widget.requestSetService
                  .isUsedElseWhere(v, AssignmentType.MEMBER),
              positionDesc: "Выберите члена бригады",
              current: teamMember,
              employees: employees,
              onChanged: (value) => widget.requestSetService
                  .addMemberEmployee(value)
                  .then((value) {
                if (mounted)
                  setState(() {
                    _hasExtraField = false;
                  });
                return value;
              }),
              onRemove: (value) {
                final result = value == null
                    ? Future.value(true)
                    : widget.requestSetService.removeEmployee(value);
                return result.then((value) {
                  if (mounted)
                    setState(() {
                      if (value == null) _hasExtraField = false;
                    });
                  return value;
                });
              },
            ),
          ));
}

class _EmployeeSelector extends StatefulWidget {
  final Iterable<Employee> employees;
  final String positionDesc;
  final Employee current;
  final bool Function(Employee) isUsed;
  final Future<bool> Function(Employee) onChanged;
  final Future<bool> Function(Employee) onRemove;

  const _EmployeeSelector({
    @required this.employees,
    @required this.positionDesc,
    @required this.isUsed,
    @required this.current,
    @required this.onChanged,
    this.onRemove,
  });

  @override
  State<StatefulWidget> createState() => __EmployeeSelectorState();
}

class __EmployeeSelectorState extends State<_EmployeeSelector> {
  bool _isLoading = false;

  void _doAction(BuildContext context, Future<bool> action()) {
    setState(() {
      _isLoading = true;
    });
    action().then((isOk) {
      if (mounted)
        setState(() {
          _isLoading = false;
          if (!isOk) {
            context.read<WorksheetMasterBloc>().add(
                WorksheetShowNotificationEvent('Не удалось выполить действие'));
          }
        });
    });
  }

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 20.0,
                height: 20.0,
                child: CircularProgressIndicator(),
              ),
            ),
          if (widget.onRemove != null)
            IconButton(
              icon: FaIcon(
                FontAwesomeIcons.timesCircle,
                size: 16.0,
              ),
              onPressed: () =>
                  _doAction(context, () => widget.onRemove(widget.current)),
            ),
          Expanded(
            child: DropdownButtonFormField<Employee>(
              autovalidateMode: AutovalidateMode.always,
              value: widget.current,
              validator: (value) {
                return value == null || value.name.isEmpty
                    ? widget.positionDesc
                    : (widget.isUsed(value) ? 'Значение дублируется' : null);
              },
              items: {widget.current, ...widget.employees}
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
              onChanged: (newValue) {
                if (newValue == null) return;
                _doAction(context, () => widget.onChanged(newValue));
              },
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
