import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/editor/request_editor_dialog/request_editor_bloc.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// Dialog for editing [RequestEntity].
class RequestEditorDialog extends StatelessWidget {
  /// Current [RequestEntity] to be edited. If `null` then new request entity
  /// will be created
  final RequestEntity? initial;

  final Validator<RequestEntity> validator;
  final AbstractRepositoryController<RequestEntity> controller;

  const RequestEditorDialog({
    Key? key,
    this.initial,
    required this.validator,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestEditorBloc>(
      create: (_) => RequestEditorBloc(
        initialRequest: initial,
        requestValidator: validator,
        requestController: controller,
        requestTypeRepository: Modular.get(),
      ),
      child: BlocConsumer<RequestEditorBloc, RequestEditorState>(
        buildWhen: (_, curr) => curr is RequestEditorShowDataState,
        builder: (context, state) {
          if (state is RequestEditorShowDataState) {
            return _RequestEditorView(state);
          }
          throw 'Unsupported state: $state';
        },
        listener: (context, state) {
          if (state is RequestValidationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Ошибка сохранения заявки: ${state.error}'),
            ));
          } else if (state is RequestEditingCompletedState) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

class _RequestEditorView extends StatefulWidget {
  final RequestEditorShowDataState dataState;

  const _RequestEditorView(this.dataState);

  @override
  __RequestEditorViewState createState() => __RequestEditorViewState();
}

class __RequestEditorViewState extends State<_RequestEditorView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _lsController;
  late TextEditingController _addressController;
  late TextEditingController _nameController;
  late TextEditingController _counterController;
  late TextEditingController _additionalController;

  late RequestType? _currentRequestType;
  late bool _isValid;

  __RequestEditorViewState();

  @override
  void initState() {
    super.initState();

    RequestEntity request = widget.dataState.current;

    _isValid = !request.isNew;
    _currentRequestType = request.requestType;
    _lsController = TextEditingController(
        text: request.accountId?.toString().padLeft(6, '0') ?? "");
    _addressController = TextEditingController(text: request.address);
    _nameController = TextEditingController(text: request.name);
    _counterController = TextEditingController(text: request.counterInfo);
    _additionalController = TextEditingController(text: request.additionalInfo);
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
    final request = widget.dataState.current;
    return AlertDialog(
      actionsPadding: const EdgeInsets.only(bottom: 16.0, right: 24.0),
      title: Text(
        request.isNew
            ? 'Создание заявки'
            : 'Редактирование заявки | Л/С №${request.printableAccountId}',
        textAlign: TextAlign.center,
      ),
      content: Container(
        height: 520.0,
        padding: EdgeInsets.all(16.0),
        child: _buildForm(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Отмена"),
        ),
        const SizedBox(width: 18.0),
        if (_isValid)
          ElevatedButton(
            onPressed: () => _pushUpdates(context),
            child: Text("Сохранить"),
          ),
      ],
    );
  }

  void _pushUpdates(BuildContext context) =>
      context.read<RequestEditorBloc>().add(UpdateRequestFieldsEvent(
            name: _nameController.text,
            additionalInfo: _additionalController.text,
            address: _addressController.text,
            counterInfo: _counterController.text,
            accountId: _lsController.text,
            requestType: _currentRequestType,
          ));

  Widget _buildForm() => Form(
        onChanged: () {
          final isValid = _formKey.currentState!.validate();
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
                  children: [
                    Text("Лицевой счёт: "),
                    const SizedBox(width: 8.0),
                    SizedBox(
                      width: 80.0,
                      child: TextFormField(
                        controller: _lsController,
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) => value?.characters.every(
                                  (element) =>
                                      element.startsWith(RegExp('[0-9]')),
                                ) ??
                                false
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
                  children: [
                    Text("Тип заявки: "),
                    const SizedBox(width: 8.0),
                    _RequestTypeChooser(
                      widget.dataState.availableRequestTypes,
                      _currentRequestType,
                      (newRequestType) => setState(() {
                        _currentRequestType = newRequestType;
                      }),
                    ),
                  ],
                ),
              ],
            ),
            ..._createInputField("ФИО: ", "Введите ФИО", _nameController),
            ..._createInputField(
                "Адрес: ", "Введите адрес", _addressController),
            ..._createInputField("Прибор учёта: ", null, _counterController,
                limit: 36),
            ..._createInputField("Дополнительно: ", null, _additionalController,
                limit: 56),
          ],
        ),
      );

  Iterable<Widget> _createInputField(
    String label,
    String? errorHint,
    TextEditingController controller, {
    int limit = 30,
  }) sync* {
    yield SizedBox(height: 24);
    yield Row(
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
            maxLength: limit,
            validator: (value) => errorHint != null && (value?.isEmpty ?? true)
                ? errorHint
                : null,
          ),
        )
      ],
    );
  }
}

class _RequestTypeChooser extends StatelessWidget {
  final List<RequestType> availableRequestTypes;
  final RequestType? current;
  final void Function(RequestType? newRequestType) onRequestTypeChanged;

  const _RequestTypeChooser(
    this.availableRequestTypes,
    this.current,
    this.onRequestTypeChanged,
  );

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 184.0,
        child: DropdownButtonFormField<RequestType>(
          autovalidateMode: AutovalidateMode.always,
          validator: (value) => value == null ? "Тип не выбран" : null,
          value: current,
          items: availableRequestTypes
              .map((e) => DropdownMenuItem(value: e, child: Text(e.shortName)))
              .toList(),
          onChanged: onRequestTypeChanged,
        ),
      );
}
