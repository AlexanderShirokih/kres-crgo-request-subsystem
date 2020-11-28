import 'package:flutter/material.dart';
import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/models/position.dart';
import 'package:kres_requests2/repo/positions_repository.dart';
import 'package:kres_requests2/screens/management/base_editor_dialog.dart';

import 'commons.dart';

/// Dialog for editing [Employee] items
class EmployeeEditorDialog extends BaseEditorDialog {
  final PositionsRepository positionsRepository;

  EmployeeEditorDialog(Employee employee, this.positionsRepository)
      : assert(positionsRepository != null),
        super(entity: employee, encoder: Employee.encoder());

  @override
  _EmployeeEditorDialogState createState() => _EmployeeEditorDialogState();
}

class _EmployeeEditorDialogState extends BaseEditorDialogState<Employee> {
  static const _kLabelsWidth = 160.0;

  List<Position> _fetchedPositions;
  List<int> _accessGroups;
  TextEditingController _nameController;
  Position _position;
  EmployeeStatus _status;
  int _accessGroup;

  @override
  void initState() {
    _accessGroups = const [2, 3, 4, 5];
    (widget as EmployeeEditorDialog).positionsRepository.getAll().then((value) {
      if (mounted) {
        setState(() {
          _fetchedPositions = value;
        });
      }
    });

    _position = entity.position;
    _accessGroup = entity?.accessGroup;
    _status = entity?.status;
    _nameController = TextEditingController(text: entity?.name ?? '');
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget buildLayout() => Column(
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
      );

  @override
  Employee onSave() => Employee(
        name: _nameController.text,
        position: _position,
        accessGroup: _accessGroup,
        status: _status ?? EmployeeStatus.WORKS,
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

  Widget _buildGroupField() => buildDropdownField(
      labelName: 'Группа э/б.: ',
      labelWidth: _kLabelsWidth,
      value: _accessGroup,
      valueExtractor: (e) => '$e гр.',
      items: _accessGroups,
      buttonWidth: 80.0,
      onChanged: (newGroup) => setState(() {
            _accessGroup = newGroup;
          }));

  Widget _buildPositionField() => buildDropdownField(
      labelName: 'Должность: ',
      labelWidth: _kLabelsWidth,
      value: _position,
      valueExtractor: (pos) => pos.name,
      items: _fetchedPositions,
      buttonWidth: 140.0,
      onChanged: (newPosition) => setState(() {
            _position = newPosition;
          }));

  Widget _buildNameField() => buildLabeledTextField(
        maxLength: 80,
        labelWidth: _kLabelsWidth,
        fieldWidth: 300.0,
        fieldName: 'Ф.И.О. работника: ',
        fieldController: _nameController,
        validatorPredicate: (text) => text == null || text.isEmpty,
      );
}
