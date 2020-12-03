import 'package:flutter/material.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

import '../common.dart';

/// Dialog for editing startup configurations
class InitialConfigDialog extends StatefulWidget {
  final SettingsRepository settingsRepository;

  const InitialConfigDialog(this.settingsRepository)
      : assert(settingsRepository != null);

  @override
  _InitialConfigDialogState createState() => _InitialConfigDialogState();
}

class _InitialConfigDialogState extends State<InitialConfigDialog> {
  static const _kLabelsWidth = 160.0;

  final _formKey = GlobalKey<FormState>();

  TextEditingController _serverHost;
  bool _isValid = false;

  @override
  void initState() {
    _serverHost = TextEditingController(
        text: widget.settingsRepository.serverHost ?? 'localhost');
    super.initState();
  }

  @override
  void dispose() {
    _serverHost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Глобальные настройки'),
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
              ? () {
                  widget.settingsRepository.serverHost = _serverHost.text;
                  Navigator.pop(context);
                }
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
            const SizedBox(height: 12.0),
            _buildHostField(),
          ],
        ),
      );

  Widget _buildHostField() => buildLabeledTextField(
        fieldName: 'Адрес сервера (хост): ',
        maxLength: 80,
        labelWidth: _kLabelsWidth,
        fieldWidth: 280.0,
        fieldController: _serverHost,
        validatorPredicate: (text) => text == null || text.isEmpty,
      );
}
