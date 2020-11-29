import 'package:flutter/material.dart';
import 'package:kres_requests2/models/counting_point.dart';

import 'base_editor_dialog.dart';
import '../common.dart';

/// Dialog for editing [CounterType] items
class CounterTypeEditorDialog extends BaseEditorDialog<CounterType> {
  CounterTypeEditorDialog(CounterType counterType)
      : super(
          entity: counterType,
          encoder: CounterType.encoder(),
        );

  @override
  State<StatefulWidget> createState() => _CounterTypeEditorState();
}

class _CounterTypeEditorState extends BaseEditorDialogState<CounterType> {
  TextEditingController _nameController;
  CounterAccuracy _accuracy;
  bool _singlePhased;
  int _bits;

  @override
  void initState() {
    super.initState();
    _bits = entity?.bits;
    _singlePhased = entity?.singlePhased;
    _accuracy = entity?.accuracy;
    _nameController = TextEditingController(text: entity?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  CounterType onSave() => CounterType(
        name: _nameController.text,
        accuracy: _accuracy,
        singlePhased: _singlePhased,
        bits: _bits,
      );

  @override
  Widget buildLayout() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameField(),
          const SizedBox(height: 12.0),
          _buildAccuracyField(),
          const SizedBox(height: 12.0),
          _buildBitsField(),
          const SizedBox(height: 12.0),
          _buildPhasesField(),
        ],
      );

  Widget _buildPhasesField() => buildDropdownField<bool>(
        labelName: 'Фазность: ',
        buttonWidth: 80.0,
        value: _singlePhased,
        items: [true, false],
        valueExtractor: (isSinglePhased) => isSinglePhased ? '1 ф.' : '3 ф.',
        onChanged: (isSinglePhased) => setState(() {
          _singlePhased = isSinglePhased;
        }),
      );

  Widget _buildBitsField() => buildDropdownField<int>(
        labelName: 'Разрядность: ',
        buttonWidth: 80.0,
        value: _bits,
        items: [4, 5, 6, 7, 8],
        valueExtractor: (b) => b.toString(),
        onChanged: (newBits) => setState(() {
          _bits = newBits;
        }),
      );

  Widget _buildAccuracyField() => buildDropdownField<CounterAccuracy>(
        labelName: 'Класс точности: ',
        buttonWidth: 80.0,
        items: CounterAccuracy.values,
        value: _accuracy,
        valueExtractor: (a) => a.describeValue(),
        onChanged: (newAccuracy) => setState(() {
          _accuracy = newAccuracy;
        }),
      );

  Widget _buildNameField() => buildLabeledTextField(
        fieldName: 'Тип: ',
        fieldWidth: 300.0,
        fieldController: _nameController,
        maxLength: 24,
      );
}
