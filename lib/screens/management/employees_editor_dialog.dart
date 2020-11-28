import 'package:flutter/material.dart';
import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/models/position.dart';
import 'package:kres_requests2/repo/positions_repository.dart';

/// Dialog for editing [Employee] items
class EmployeeEditorDialog extends StatefulWidget {
  final PositionsRepository positionsRepository;
  final Employee employee;
  final bool isNew;

  const EmployeeEditorDialog(this.employee, this.positionsRepository)
      : assert(positionsRepository != null),
        isNew = employee == null;

  @override
  _EmployeeEditorDialogState createState() => _EmployeeEditorDialogState();
}

class _EmployeeEditorDialogState extends State<EmployeeEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  List<Position> _fetchedPositions;
  List<int> _accessGroups;
  TextEditingController _nameController;
  Position _position;
  EmployeeStatus _status;
  int _accessGroup;
  bool _isValid = true;

  @override
  void initState() {
    _accessGroups = const [2, 3, 4, 5];
    widget.positionsRepository.getAll().then((value) {
      if (mounted) {
        setState(() {
          _fetchedPositions = value;
        });
      }
    });

    _isValid = !widget.isNew;
    _position = widget.employee?.position;
    _accessGroup = widget.employee?.accessGroup;
    _status = widget.employee?.status;
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? 'Добавление записи' : 'Редактирование записи'),
      content: Container(
        width: 460.0,
        child: _buildLayout(),
      ),
      actionsPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      actions: [
        FlatButton(
          child: Text('Отменить'),
          onPressed: () => Navigator.pop(context, null),
        ),
        const SizedBox(width: 12.0),
        OutlinedButton(
          child: Text('Сохранить'),
          onPressed: _isValid
              ? () => Navigator.pop(
                  context,
                  Employee(
                    name: _nameController.text,
                    position: _position,
                    accessGroup: _accessGroup,
                    status: _status ?? EmployeeStatus.WORKS,
                  ).toJson())
              : null,
        ),
      ],
    );
  }

  Widget _buildLayout() => Form(
        onChanged: () {
          final isValid = _formKey.currentState.validate();
          if (_isValid != isValid)
            setState(() {
              _isValid = isValid;
            });
        },
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 12.0),
            _buildPositionField(),
            const SizedBox(height: 12.0),
            _buildGroupField(),
            const SizedBox(height: 12.0),
            if (_status == EmployeeStatus.FIRED) _buildUnfireField(),
          ],
        ),
      );

  Widget _buildUnfireField() => Row(
        children: [
          Text('Сотрудник уволен.'),
          const SizedBox(width: 18.0),
          RaisedButton(
            child: Text('Восстановить'),
            onPressed: () => setState(() {
              _status = EmployeeStatus.WORKS;
            }),
          ),
        ],
      );

  Widget _buildGroupField() => Row(
        children: [
          _buildFixedWidthText('Группа э/б.: '),
          SizedBox(
            width: 80.0,
            child: DropdownButtonFormField<int>(
              autovalidateMode: AutovalidateMode.always,
              validator: (value) => value == null ? '' : null,
              value: _accessGroup,
              items: _accessGroups
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text('$e гр.'),
                    ),
                  )
                  .toList(),
              onChanged: (newGroup) => setState(() {
                _accessGroup = newGroup;
              }),
            ),
          )
        ],
      );

  Widget _buildPositionField() => Row(
        children: [
          _buildFixedWidthText('Должность: '),
          SizedBox(
            width: 140.0,
            child: DropdownButtonFormField<Position>(
              autovalidateMode: AutovalidateMode.always,
              validator: (value) => value == null ? '' : null,
              value: _position,
              items: _fetchedPositions == null
                  ? null
                  : _fetchedPositions
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name),
                        ),
                      )
                      .toList(),
              onChanged: (newPosition) => setState(() {
                _position = newPosition;
              }),
            ),
          )
        ],
      );

  Widget _buildNameField() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          _buildFixedWidthText('Ф.И.О. работника: '),
          SizedBox(
            width: 300.0,
            child: TextFormField(
              controller: _nameController,
              autovalidateMode: AutovalidateMode.always,
              validator: (text) => text == null || text.isEmpty ? '' : null,
              maxLength: 80,
            ),
          )
        ],
      );

  Widget _buildFixedWidthText(String text) => ConstrainedBox(
        constraints: BoxConstraints(minWidth: 160.0),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
        ),
      );
}
