import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/settings/employee_module.dart';
import 'package:kres_requests2/data/settings/position_module.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/screens/common/save_changes_dialog.dart';
import 'package:kres_requests2/screens/settings/employees/bloc/employee_bloc.dart';

/// Manages employees.
class EmployeesScreen extends StatelessWidget {
  final EmployeeModule employeeModule;
  final PositionModule positionModule;

  const EmployeesScreen({
    Key key,
    @required this.employeeModule,
    @required this.positionModule,
  }) : super(key: key);

  Widget _buildActionButton() =>
      BlocBuilder<EmployeeBloc, EmployeeState>(builder: (context, state) {
        if (state is EmployeeDataState && state.canSave) {
          return FloatingActionButton(
            tooltip: 'Сохранить изменения',
            child: FaIcon(FontAwesomeIcons.solidSave),
            onPressed: () => context.read<EmployeeBloc>().add(EmployeeApply()),
          );
        } else {
          return const SizedBox();
        }
      });

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => EmployeeBloc(
          employeeModule.employeeController,
          positionModule.positionRepository,
          employeeModule.employeeValidator,
        ),
        child: Builder(
          builder: (context) => WillPopScope(
            onWillPop: () async {
              // ignore: close_sinks
              final bloc = context.read<EmployeeBloc>();

              if (bloc.state is EmployeeDataState) {
                final dataState = bloc.state as EmployeeDataState;
                if (dataState.hasUnsavedChanges && dataState.canSave) {
                  final canPop = await showDialog<bool /*?*/ >(
                      context: context, builder: (_) => SaveChangesDialog());

                  if (canPop == null) {
                    // Cancelled
                    return false;
                  }

                  if (!canPop) {
                    // Cannot be popped before changed
                    await bloc.commitChanges();
                  }

                  // Can be popped by discarding changes
                  return true;
                }
              }

              return true;
            },
            child: Scaffold(
              floatingActionButton: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildActionButton(),
              ),
              appBar: AppBar(
                title: Text('Сотрудники'),
                actions: [
                  _buildActionButtons(),
                  Builder(
                    builder: (BuildContext context) => ElevatedButton.icon(
                      icon: FaIcon(FontAwesomeIcons.userPlus),
                      label: Text('Добавить сотрудника'),
                      onPressed: () =>
                          context.read<EmployeeBloc>().add(EmployeeAddItem()),
                    ),
                  ),
                  SizedBox(width: 42.0),
                ],
              ),
              body: BlocBuilder<EmployeeBloc, EmployeeState>(
                builder: (context, state) {
                  if (state is EmployeeDataState) {
                    return _EmployeeTableContent(
                      employees: state.employees,
                      positions: state.availablePositions,
                      groups: state.groups,
                      bloc: context.watch<EmployeeBloc>(),
                    );
                  }
                  return Center(
                    child: Text('Нет данных :('),
                  );
                },
              ),
            ),
          ),
        ),
      );

  Widget _buildActionButtons() =>
      BlocBuilder<EmployeeBloc, EmployeeState>(builder: (context, state) {
        if (state is EmployeeDataState) {
          return Row(
            children: _spreadActionButtons(context, state).toList(),
          );
        } else {
          return const SizedBox();
        }
      });

  Iterable<Widget> _spreadActionButtons(
      BuildContext context, EmployeeDataState state) sync* {
    if (state.hasUnsavedChanges) {
      yield IconButton(
        icon: Icon(Icons.redo),
        tooltip: 'Отменить',
        onPressed: () => context.read<EmployeeBloc>().add(EmployeeUndoAction()),
      );
      yield SizedBox(width: 36.0);
    }
  }
}

class _EmployeeTableContent extends StatefulWidget {
  final List<Employee> employees;
  final List<Position> positions;
  final List<int> groups;
  final EmployeeBloc bloc;

  const _EmployeeTableContent({
    Key key,
    @required this.employees,
    @required this.positions,
    @required this.groups,
    @required this.bloc,
  }) : super(key: key);

  @override
  __EmployeeTableContentState createState() => __EmployeeTableContentState();
}

class __EmployeeTableContentState extends State<_EmployeeTableContent> {
  ScrollController _scrollController;
  bool _wasRebuilt = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.employees.isEmpty) {
      return Center(
          child: Text('Таблица пуста',
              style: Theme.of(context).textTheme.headline3));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_wasRebuilt) {
        _scrollController.animateTo(
          100000.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
      _wasRebuilt = true;
    });
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          elevation: 8.0,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 460.0,
              ),
              child: DataTable(
                dataTextStyle: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(color: Colors.grey),
                headingTextStyle: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 18.0),
                columns: _createHeader(),
                rows: _createData(widget.employees),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _createHeader() => [
        DataColumn(label: Text('ФИО')),
        DataColumn(label: Text('Должность')),
        DataColumn(label: Text('Группа допуска'), numeric: true),
        DataColumn(label: const SizedBox()),
      ];

  List<DataRow> _createData(List<Employee> employees) {
    return employees.map((e) {
      return DataRow(
        cells: [
          DataCell(_createNameField(e)),
          DataCell(_createPositionDropdown(e)),
          DataCell(_createGroupDropdown(e)),
          DataCell(_createDeleteButton(e)),
        ],
      );
    }).toList();
  }

  void _fireItemChanged(Employee source, Employee updated) {
    widget.bloc.add(EmployeeUpdateItem(source, updated));
  }

  Widget _createDeleteButton(Employee e) => _DeleteButton(
        key: ValueKey(e),
        onPressed: () => widget.bloc.add(EmployeeDeleteItem(e)),
      );

  Widget _createNameField(Employee e) => _EditableNameCell(
        key: ValueKey(e),
        width: 260.0,
        name: e.name,
        onChanged: (newValue) => _fireItemChanged(e, e.copy(name: newValue)),
      );

  Widget _createPositionDropdown(Employee e) => SizedBox(
        key: ValueKey(e),
        width: 140.0,
        child: DropdownButton<Position>(
          onChanged: (newPosition) =>
              _fireItemChanged(e, e.copy(position: newPosition)),
          value: e.position,
          items: widget.positions
              .map(
                (e) => DropdownMenuItem<Position>(
                  child: Text(e.name),
                  value: e,
                ),
              )
              .toList(),
        ),
      );

  Widget _createGroupDropdown(Employee e) => SizedBox(
        key: ValueKey(e),
        width: 100.0,
        child: DropdownButton<int>(
          onChanged: (newGroup) =>
              _fireItemChanged(e, e.copy(accessGroup: newGroup)),
          value: e.accessGroup,
          items: widget.groups
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

class _DeleteButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _DeleteButton({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  @override
  __DeleteButtonState createState() => __DeleteButtonState();
}

class __DeleteButtonState extends State<_DeleteButton> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHighlighted = true;
      }),
      onExit: (_) => setState(() {
        _isHighlighted = false;
      }),
      child: IconButton(
        icon: Icon(
          Icons.delete,
          color: _isHighlighted ? Theme.of(context).errorColor : null,
        ),
        onPressed: _isHighlighted ? widget.onPressed : null,
      ),
    );
  }
}

class _EditableNameCell extends StatefulWidget {
  final String name;
  final double width;
  final Function(String) onChanged;

  const _EditableNameCell({
    Key key,
    @required this.name,
    @required this.width,
    @required this.onChanged,
  }) : super(key: key);

  @override
  _EditableTextFieldState createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<_EditableNameCell> {
  /*late*/
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: TextFormField(
        autovalidateMode: AutovalidateMode.always,
        maxLength: 50,
        validator: (value) => value.isEmpty ? "Введите ФИО" : null,
        controller: _textController,
        onEditingComplete: () => widget.onChanged(_textController.text),
        decoration: InputDecoration(
          border: InputBorder.none,
          counter: SizedBox(),
        ),
        style: Theme.of(context).dataTableTheme.dataTextStyle,
      ),
    );
  }
}
