import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditableField {
  final String caption;
  final RegExp validator;
  final String key;
  final String initialValue;
  final int limit;
  final bool numeric;

  const EditableField(
      this.caption, this.key, this.initialValue, this.limit, this.validator,
      [this.numeric = false]);
}

/// Shows interface for editing some entity type
class ManagementEditorDialog extends StatefulWidget {
  final bool isNew;
  final List<EditableField> fields;

  ManagementEditorDialog(this.isNew, this.fields);

  @override
  _ManagementEditorDialogState createState() => _ManagementEditorDialogState();
}

class _ManagementEditorDialogState<E> extends State<ManagementEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isValid;
  Map<EditableField, TextEditingController> _fieldControllers;

  @override
  void initState() {
    _isValid = !widget.isNew;
    _fieldControllers = Map.fromIterable(
      widget.fields,
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.isNew ? 'Добавление записи' : 'Редактирование записи'),
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
                    _fieldControllers.map((key, value) => MapEntry(
                        key.key, _handleType(key.numeric, value.text))),
                  )
              : null,
        ),
      ],
    );
  }

  dynamic _handleType(bool isNumeric, String text) =>
      isNumeric ? int.parse(text) : text;

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
                            (value != null && e.key.validator.hasMatch(value))
                                ? null
                                : '',
                      ),
                    )
                  ],
                ),
              )
              .toList(),
        ),
      );
}
