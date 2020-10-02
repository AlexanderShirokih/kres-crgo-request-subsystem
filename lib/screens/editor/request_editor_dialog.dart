import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kres_requests2/data/request_entity.dart';
import 'package:kres_requests2/repo/config_repository.dart';

class RequestEditorDialog extends StatefulWidget {
  final RequestEntity editingRequest;

  const RequestEditorDialog({this.editingRequest});

  @override
  _RequestEditorDialogState createState() => _RequestEditorDialogState(
        editingRequest?.copy() ?? RequestEntity.empty(),
        editingRequest == null,
      );
}

class _RequestEditorDialogState extends State<RequestEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _availableRequestTypes = [
    "замена",
    "по сроку",
    "опломб.",
    "распломб.",
    "тех. пров.",
    "подкл.",
    "ЦОП",
    "Другое"
  ];
  TextEditingController _lsController;
  TextEditingController _addressController;
  TextEditingController _nameController;
  TextEditingController _counterController;
  TextEditingController _additionalController;

  final RequestEntity _request;
  String _requestType;
  bool _isValid;
  bool _isNew;

  _RequestEditorDialogState(this._request, this._isNew)
      : assert(_request != null),
        assert(_isNew != null) {
    _isValid = !_isNew;
  }

  @override
  void initState() {
    super.initState();
    _requestType = _request.reqType;
    _lsController = TextEditingController(
        text: _request.accountId?.toString()?.padLeft(6, '0') ?? "");
    _addressController = TextEditingController(text: _request.address);
    _nameController = TextEditingController(text: _request.name);
    _counterController = TextEditingController(text: _request.counterInfo);
    _additionalController =
        TextEditingController(text: _request.additionalInfo);
  }

  @override
  void dispose() {
    super.dispose();
    _lsController.dispose();
    _addressController.dispose();
    _nameController.dispose();
    _counterController.dispose();
    _additionalController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.only(bottom: 16.0, right: 24.0),
      title: Text(
        _isNew
            ? 'Создание заявки'
            : 'Редактирование заявки | Л/С №${_request.accountId?.toString()?.padLeft(6, '0') ?? "--"}',
        textAlign: TextAlign.center,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560.0),
        child: Container(
          height: 420.0,
          padding: EdgeInsets.all(16.0),
          child: Form(
            onChanged: () {
              final isValid = _formKey.currentState.validate();
              if (_isValid != isValid)
                setState(() {
                  _isValid = isValid;
                });
            },
            autovalidateMode: AutovalidateMode.always,
            key: _formKey,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text("Лицевой счёт: "),
                        const SizedBox(width: 8.0),
                        SizedBox(
                          width: 80.0,
                          child: TextFormField(
                            controller: _lsController,
                            autovalidateMode: AutovalidateMode.always,
                            validator: (value) => value.characters.every(
                              (element) => element.startsWith(RegExp('[0-9]')),
                            )
                                ? null
                                : "",
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 36.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      children: [
                        Text("Тип заявки: "),
                        const SizedBox(width: 8.0),
                        _RequestTypeChooser(
                            _availableRequestTypes, _requestType, (newReqType) {
                          _requestType = newReqType;
                        }),
                      ],
                    ),
                  ],
                ),
                ..._createInputField("ФИО: ", "Введите ФИО", _nameController),
                ..._createInputField(
                    "Адрес: ", "Введите адрес", _addressController),
                ..._createInputField(
                    "Прибор учёта: ", null, _counterController),
                ..._createInputField(
                    "Дополнительно: ", null, _additionalController),
              ],
            ),
          ),
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Отмена"),
        ),
        const SizedBox(width: 18.0),
        if (_isValid)
          RaisedButton(
            color: Theme.of(context).accentColor,
            padding: EdgeInsets.all(18.0),
            onPressed: () {
              Navigator.pop(
                context,
                RequestEntity(
                  name: _nameController.text,
                  additionalInfo: _additionalController.text,
                  address: _addressController.text,
                  counterInfo: _counterController.text,
                  accountId: _lsController.text.isNotEmpty
                      ? int.parse(_lsController.text)
                      : null,
                  reqType: _requestType,
                  fullReqType: context
                      .repository<ConfigRepository>()
                      .getFullRequestName(_requestType),
                ),
              );
            },
            child: Text("Сохранить"),
          ),
      ],
    );
  }

  Iterable<Widget> _createInputField(
    String label,
    String errorHint,
    TextEditingController controller,
  ) sync* {
    yield SizedBox(height: 24);
    yield Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 130.0,
          ),
          child: Text(label),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: TextFormField(
            controller: controller,
            autovalidateMode: AutovalidateMode.always,
            validator: (value) =>
                errorHint != null && value.isEmpty ? errorHint : null,
          ),
        )
      ],
    );
  }
}

class _RequestTypeChooser extends StatefulWidget {
  final List<String> availableRequestTypes;
  final String initialRequestType;
  final Function(String) onReqTypeChanged;

  const _RequestTypeChooser(
    this.availableRequestTypes,
    this.initialRequestType,
    this.onReqTypeChanged,
  )   : assert(onReqTypeChanged != null),
        assert(availableRequestTypes != null);

  @override
  __RequestTypeChooserState createState() =>
      __RequestTypeChooserState(availableRequestTypes, initialRequestType);
}

class __RequestTypeChooserState extends State<_RequestTypeChooser> {
  List<String> _availableRequestTypes;

  bool _isExtended = false;
  String _currentType;

  __RequestTypeChooserState(
      List<String> availableRequestTypes, String initialRequestType) {
    _availableRequestTypes = [
      ...availableRequestTypes,
      if (initialRequestType != null) initialRequestType
    ].toSet().toList();
    _currentType = initialRequestType;
  }

  @override
  Widget build(BuildContext context) {
    return _isExtended
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _createFormField(),
              const SizedBox(width: 6.0),
              SizedBox(
                width: 96.0,
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  validator: (val) => val.isEmpty ? "Значение пусто" : null,
                  onFieldSubmitted: (value) => setState(() {
                    if (value.isNotEmpty) {
                      _availableRequestTypes.insert(0, value);
                      _availableRequestTypes =
                          _availableRequestTypes.toSet().toList();
                      _currentType = value;
                    } else
                      _currentType = null;
                    _isExtended = false;
                  }),
                ),
              ),
            ],
          )
        : _createFormField();
  }

  Widget _createFormField() => SizedBox(
        width: 164.0,
        child: DropdownButtonFormField<String>(
          autovalidateMode: AutovalidateMode.always,
          validator: (value) => value == null ? "Тип не выбран" : null,
          value: _currentType,
          items: _availableRequestTypes
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() {
            _isExtended = value == _availableRequestTypes.last;
            _currentType = value;
            widget.onReqTypeChanged(value);
          }),
        ),
      );
}
