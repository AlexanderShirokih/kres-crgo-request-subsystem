import 'package:flutter/material.dart';
import 'package:kres_requests2/models/user.dart';

import '../common.dart';

/// Dialog for editing [User]s
class UserEditorDialog extends StatefulWidget {
  final User user;
  final bool isNew;

  const UserEditorDialog(this.user) : isNew = user == null;

  @override
  _UserEditorDialogState createState() => _UserEditorDialogState();
}

class _UserEditorDialogState extends State<UserEditorDialog> {
  static const _kLabelsWidth = 160.0;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController;
  TextEditingController _passwordController;
  UserAuthority _authority;
  bool _isValid = true;

  @override
  void initState() {
    _isValid = !widget.isNew;
    _authority = widget.user?.authority;
    _nameController = TextEditingController(text: widget.user?.name ?? '');
    _passwordController = TextEditingController();
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
                  User(
                    name: _nameController.text,
                    password: _passwordController.text.isEmpty
                        ? null
                        : _passwordController.text,
                    authority: _authority,
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
            _buildPasswordField(),
            const SizedBox(height: 12.0),
            _buildAuthorityField(),
          ],
        ),
      );

  Widget _buildAuthorityField() => buildDropdownField<UserAuthority>(
      labelName: 'Полномочия: ',
      labelWidth: _kLabelsWidth,
      value: _authority,
      valueExtractor: (e) => e.getLocalizedDescription(),
      items: User.allowedAuthorities(),
      buttonWidth: 140.0,
      onChanged: (newAuthority) => setState(() {
            _authority = newAuthority;
          }));

  Widget _buildNameField() => buildLabeledTextField(
        maxLength: 80,
        labelWidth: _kLabelsWidth,
        fieldWidth: 300.0,
        fieldName: 'Логин: ',
        fieldController: _nameController,
        validatorPredicate: (text) => text == null || text.isEmpty,
      );

  Widget _buildPasswordField() => buildLabeledTextField(
        obscureText: true,
        maxLength: 40,
        labelWidth: _kLabelsWidth,
        fieldWidth: 300.0,
        fieldName: 'Пароль: ',
        fieldController: _passwordController,
        validatorPredicate: (text) =>
            ((text != null && text.length > 0) || widget.isNew) &&
            text.length < 6,
      );
}
