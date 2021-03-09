import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/data/settings/employee_module.dart';
import 'package:kres_requests2/data/settings/position_module.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:kres_requests2/screens/common/save_changes_dialog.dart';
import 'package:kres_requests2/screens/common/table_view.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_events.dart';
import 'package:kres_requests2/screens/settings/common/bloc/undoable_state.dart';
import 'package:kres_requests2/screens/settings/employees/bloc/employee_bloc.dart';

/// Manages employees.
class EmployeesScreen extends StatelessWidget {
  final EmployeeModule employeeModule;
  final PositionModule positionModule;

  const EmployeesScreen({
    Key? key,
    required this.employeeModule,
    required this.positionModule,
  }) : super(key: key);

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

              if (bloc.state is DataState<EmployeeData>) {
                final dataState = bloc.state as DataState<EmployeeData>;
                if (dataState.hasUnsavedChanges && dataState.canSave) {
                  final canPop = await showDialog<bool?>(
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
                  _buildAppBarActions(),
                  Builder(
                    builder: (BuildContext context) => ElevatedButton.icon(
                      icon: FaIcon(FontAwesomeIcons.userPlus),
                      label: Text('Добавить сотрудника'),
                      onPressed: () =>
                          context.read<EmployeeBloc>().add(AddItemEvent()),
                    ),
                  ),
                  SizedBox(width: 42.0),
                ],
              ),
              body: BlocBuilder<EmployeeBloc, UndoableState<EmployeeData>>(
                builder: (context, state) {
                  if (state is DataState<EmployeeData>) {
                    return _EmployeeTableContent(
                      bloc: context.watch<EmployeeBloc>(),
                      data: state.data,
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

  Widget _buildActionButton() =>
      BlocBuilder<EmployeeBloc, UndoableState<EmployeeData>>(
          builder: (context, state) {
        if (state is DataState<EmployeeData> && state.canSave) {
          return FloatingActionButton(
            tooltip: 'Сохранить изменения',
            child: FaIcon(FontAwesomeIcons.solidSave),
            onPressed: () => context.read<EmployeeBloc>().add(ApplyEvent()),
          );
        } else {
          return const SizedBox();
        }
      });

  Widget _buildAppBarActions() =>
      BlocBuilder<EmployeeBloc, UndoableState<EmployeeData>>(
          builder: (context, state) {
        if (state is DataState<EmployeeData>) {
          return Row(
            children: _spreadActionButtons(context, state).toList(),
          );
        } else {
          return const SizedBox();
        }
      });

  Iterable<Widget> _spreadActionButtons(
      BuildContext context, DataState<EmployeeData> state) sync* {
    if (state.hasUnsavedChanges) {
      yield IconButton(
        icon: Icon(Icons.redo),
        tooltip: 'Отменить',
        onPressed: () => context.read<EmployeeBloc>().add(UndoActionEvent()),
      );
      yield SizedBox(width: 36.0);
    }
  }
}

class _EmployeeTableContent extends StatefulWidget {
  final EmployeeData data;
  final EmployeeBloc bloc;

  const _EmployeeTableContent({
    Key? key,
    required this.data,
    required this.bloc,
  }) : super(key: key);

  @override
  __EmployeeTableContentState createState() => __EmployeeTableContentState();
}

class __EmployeeTableContentState extends State<_EmployeeTableContent> {
  late ScrollController _scrollController;
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
    if (widget.data.employees.isEmpty) {
      return Center(
        child:
            Text('Таблица пуста', style: Theme.of(context).textTheme.headline3),
      );
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_wasRebuilt) {
        _scrollController.animateTo(
          100000.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
      }
      _wasRebuilt = true;
    });
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 460.0,
      ),
      child: TableView(
        controller: _scrollController,
        rowsTextStyle:
            Theme.of(context).textTheme.headline5!.copyWith(color: Colors.grey),
        headingTextStyle:
            Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 18.0),
        header: _createHeader(),
        rows: _createData(widget.data.employees),
      ),
    );
  }

  List<TableHeadingColumn> _createHeader() => [
        TableHeadingColumn(label: Text('ФИО'), preferredWidth: 320.0),
        TableHeadingColumn(label: Text('Должность'), preferredWidth: 168.0),
        TableHeadingColumn(
            label: Text('Группа допуска'), preferredWidth: 168.0),
        TableHeadingColumn(label: const SizedBox(), preferredWidth: 60.0),
      ];

  List<TableDataRow> _createData(List<Employee> employees) {
    return employees.map((e) {
      return TableDataRow(
        key: ValueKey(e),
        cells: [
          _createNameField(e),
          _createPositionDropdown(e),
          _createGroupDropdown(e),
          _createDeleteButton(e),
        ],
      );
    }).toList();
  }

  void _fireItemChanged(Employee source, Employee updated) {
    widget.bloc.add(UpdateItemEvent(source, updated));
  }

  Widget _createDeleteButton(Employee e) => _DeleteButton(
        onPressed: () => widget.bloc.add(DeleteItemEvent(e)),
      );

  Widget _createNameField(Employee e) => _EditableNameCell(
        key: e is PersistedObject ? ValueKey((e as PersistedObject).id) : null,
        width: 320.0,
        name: e.name,
        onChanged: (newValue) => _fireItemChanged(e, e.copy(name: newValue)),
      );

  Widget _createPositionDropdown(Employee e) => SizedBox(
        width: 140.0,
        child: DropdownButton<Position>(
          onChanged: (newPosition) =>
              _fireItemChanged(e, e.copy(position: newPosition)),
          value: e.position,
          items: widget.data.availablePositions
              .map(
                (e) => DropdownMenuItem<Position>(
                  child: Text(e.name),
                  value: e,
                ),
              )
              .toList(),
        ),
      );

  Widget _createGroupDropdown(Employee e) => Padding(
        padding: EdgeInsets.only(left: 20.0),
        child: DropdownButton<int>(
          key: ValueKey(e),
          onChanged: (newGroup) =>
              _fireItemChanged(e, e.copy(accessGroup: newGroup)),
          value: e.accessGroup,
          items: widget.data.groups
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
    Key? key,
    required this.onPressed,
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
    Key? key,
    required this.name,
    required this.width,
    required this.onChanged,
  }) : super(key: null);

  @override
  __EditableNameCellState createState() => __EditableNameCellState();
}

class __EditableNameCellState extends State<_EditableNameCell> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.name.isEmpty;
    _focusNode = FocusNode();
    _controller = TextEditingController(text: widget.name);
    if (_isEditing) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onEditingDone() => setState(
        () {
          _isEditing = false;
          if (widget.name != _controller.text) {
            widget.onChanged(_controller.text);
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: !_isEditing,
              autovalidateMode: AutovalidateMode.always,
              maxLines: 1,
              maxLength: 50,
              autofocus: false,
              validator: (value) => value!.length < 3 ? "Введите ФИО" : null,
              onEditingComplete: _onEditingDone,
              decoration: InputDecoration(
                border: InputBorder.none,
                counter: SizedBox(),
              ),
              style: Theme.of(context).dataTableTheme.dataTextStyle,
            ),
          ),
          if (_isEditing)
            IconButton(
              icon: FaIcon(FontAwesomeIcons.check),
              onPressed: _onEditingDone,
            )
          else
            IconButton(
              icon: FaIcon(FontAwesomeIcons.edit),
              onPressed: () => setState(
                () {
                  _focusNode.requestFocus();
                  _isEditing = true;
                },
              ),
            ),
          const SizedBox(width: 24.0),
        ],
      ),
    );
  }
}
