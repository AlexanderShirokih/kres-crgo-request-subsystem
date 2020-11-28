import 'package:flutter/material.dart';
import 'package:kres_requests2/models/encoder.dart';

/// Base class for all editor dialogs
abstract class BaseEditorDialog<T> extends StatefulWidget {
  final double dialogWidth;
  final T entity;
  final Encoder<T> encoder;
  final bool isNew;

  const BaseEditorDialog({
    @required this.entity,
    @required this.encoder,
    this.dialogWidth = 460.0,
  })  : isNew = entity == null,
        assert(dialogWidth != null);
}

abstract class BaseEditorDialogState<T> extends State<BaseEditorDialog> {
  T get entity => widget.entity;

  final _formKey = GlobalKey<FormState>();

  bool _isValid = true;

  Widget buildLayout();

  T onSave();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isNew ? 'Добавление записи' : 'Редактирование записи'),
      content: Container(
        width: widget.dialogWidth,
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
                    widget.encoder.toJson(onSave()),
                  )
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
        child: buildLayout(),
      );
}
