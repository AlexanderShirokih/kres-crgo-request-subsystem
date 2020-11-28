import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kres_requests2/models/encoder.dart';
import 'package:kres_requests2/screens/management/base_editor_dialog.dart';

class EditableField {
  final String caption;
  final String key;
  final String initialValue;
  final int limit;
  final bool numeric;

  const EditableField(this.caption, this.key, this.initialValue, this.limit,
      [this.numeric = false]);
}

class _MapEncoder extends Encoder<Map<String, dynamic>> {
  @override
  Map<String, dynamic> fromJson(Map<String, dynamic> data) => data;

  @override
  Map<String, dynamic> toJson(Map<String, dynamic> entity) => entity;
}

/// Shows interface for editing some entity type
class ManagementEditorDialog extends BaseEditorDialog {
  final List<EditableField> fields;

  ManagementEditorDialog(bool isNew, this.fields)
      : super(entity: isNew ? null : '', encoder: _MapEncoder());

  @override
  _ManagementEditorDialogState createState() => _ManagementEditorDialogState();
}

class _ManagementEditorDialogState<E>
    extends BaseEditorDialogState<Map<String, dynamic>> {
  Map<EditableField, TextEditingController> _fieldControllers;

  @override
  void initState() {
    _fieldControllers = Map.fromIterable(
      (widget as ManagementEditorDialog).fields,
      key: (e) => e,
      value: (e) => TextEditingController(text: e.initialValue),
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_fieldControllers != null)
      for (final controller in _fieldControllers.values) controller.dispose();
  }

  @override
  Map<String, dynamic> onSave() => _fieldControllers.map(
      (key, value) => MapEntry(key.key, _handleType(key.numeric, value.text)));

  dynamic _handleType(bool isNumeric, String text) =>
      isNumeric ? int.parse(text) : text;

  @override
  Widget buildLayout() => Column(
        mainAxisSize: MainAxisSize.min,
        children: _fieldControllers.entries
            .map(
              (e) => Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 130.0,
                    ),
                    child: Text(e.key.caption),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.always,
                      controller: e.value,
                      maxLength: e.key.limit,
                      validator: (value) =>
                          (value != null && value.isNotEmpty) ? null : '',
                    ),
                  )
                ],
              ),
            )
            .toList(),
      );
}
