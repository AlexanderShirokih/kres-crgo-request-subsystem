import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/editor/request_editor_dialog/request_editor_bloc.dart';
import 'package:kres_requests2/data/validators.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/utils.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// Dialog for editing [RequestEntity].
class RequestEditorDialog extends StatelessWidget {
  /// Current [RequestEntity] to be edited. If `null` then new request entity
  /// will be created
  final RequestEntity? initial;

  final WorksheetEditor worksheetEditor;
  final MappedValidator<RequestEntity> validator;

  const RequestEditorDialog({
    Key? key,
    this.initial,
    required this.worksheetEditor,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequestEditorBloc>(
      create: (_) => RequestEditorBloc(
        initial: initial,
        requestValidator: validator,
        worksheetEditor: worksheetEditor,
        requestTypeRepository: Modular.get(),
      ),
      child: BlocConsumer<RequestEditorBloc, RequestEditorState>(
        buildWhen: (_, curr) => curr is RequestEditorShowDataState,
        builder: (context, state) {
          if (state is RequestEditorShowDataState) {
            return _RequestEditorView(state, validator);
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

class _RequestEditorView extends HookWidget {
  final RequestEditorShowDataState dataState;
  final MappedValidator<RequestEntity> validator;

  const _RequestEditorView(this.dataState, this.validator);

  @override
  Widget build(BuildContext context) {
    final request = dataState.current;
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isValid = useState(false);
    final requestType = useState(request.requestType);

    final id = useTextEditingController(
        text: request.accountId?.toString().padLeft(6, '0') ?? "");
    final name = useTextEditingController(text: request.name);
    final address = useTextEditingController(text: request.address);

    final phone = useTextEditingController(text: request.phoneNumber);
    final tp = useTextEditingController(text: request.connectionPoint?.tp);
    final line = useTextEditingController(text: request.connectionPoint?.line);
    final pillar =
        useTextEditingController(text: request.connectionPoint?.pillar);
    final counterType = useTextEditingController(text: request.counter?.type);
    final counterNumber =
        useTextEditingController(text: request.counter?.number);
    final checkYear =
        useTextEditingController(text: request.counter?.checkYear?.toString());
    final checkQuarter = useState(request.counter?.checkQuarter);
    final additional = useTextEditingController(text: request.additionalInfo);

    return AlertDialog(
      actionsPadding: const EdgeInsets.only(bottom: 16.0, right: 24.0),
      title: Text(
        request.isEmpty
            ? 'Создание заявки'
            : 'Редактирование заявки | Л/С №${request.printableAccountId}',
        textAlign: TextAlign.center,
      ),
      content: Container(
        width: 640.0,
        height: 580.0,
        padding: EdgeInsets.all(16.0),
        child: Form(
          onChanged: () => isValid.value = formKey.currentState!.validate(),
          autovalidateMode: AutovalidateMode.always,
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _createMainRow(id, requestType),
              const SizedBox(height: 8.0),
              _createInputField("ФИО", "Поле ФИО не должно быть пустым", name),
              const SizedBox(height: 8.0),
              _createInputField(
                  "Адрес", "Поле адреса не должно быть пустым", address),
              const SizedBox(height: 8.0),
              _createPhoneAndConnectionPointRow(phone, tp, line, pillar),
              const SizedBox(height: 28),
              ..._createCounterRow(
                counterType,
                counterNumber,
                checkQuarter,
                checkYear,
              ),
              const SizedBox(height: 28),
              _createInputField("Дополнительно", null, additional, limit: 30),
              Divider(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("Отмена"),
          ),
        ),
        const SizedBox(width: 18.0),
        if (isValid.value)
          ElevatedButton(
            onPressed: () {
              context.read<RequestEditorBloc>().add(UpdateRequestFieldsEvent(
                    name: name.text,
                    additionalInfo: additional.text,
                    address: address.text,
                    accountId: id.text,
                    phone: phone.text,
                    counterType: counterType.text,
                    tp: tp.text,
                    line: line.text,
                    pillar: pillar.text,
                    counterNumber: counterNumber.text,
                    checkQuarter: checkQuarter.value,
                    checkYear: checkYear.text,
                    requestType: requestType.value,
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Сохранить"),
            ),
          ),
      ],
    );
  }

  Widget _createMainRow(
    TextEditingController idController,
    ValueNotifier<RequestType?> requestType,
  ) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160.0,
            child: TextFormField(
              decoration:
                  _outlinedDecoration('Лицевой счет', alwaysFloating: true),
              controller: idController,
              autovalidateMode: AutovalidateMode.always,
              validator: (value) => value?.characters.every(
                        (e) => e.startsWith(RegExp('[0-9]')),
                      ) ??
                      false
                  ? null
                  : "",
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ),
          const SizedBox(width: 36.0),
          SizedBox(
            width: 220.0,
            child: DropdownButtonFormField<RequestType>(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 17.0),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(),
                labelText: "Тип заявки",
              ),
              onChanged: (newValue) => requestType.value = newValue,
              autovalidateMode: AutovalidateMode.always,
              validator: (value) => value == null ? "Тип не выбран" : null,
              value: requestType.value,
              items: dataState.availableRequestTypes
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e.shortName)))
                  .toList(),
            ),
          ),
        ],
      );

  Widget _createInputField(
    String label,
    String? errorHint,
    TextEditingController controller, {
    int limit = 30,
  }) =>
      Expanded(
        child: TextFormField(
          decoration: _outlinedDecoration(label, hasCounter: true),
          controller: controller,
          autovalidateMode: AutovalidateMode.always,
          maxLength: limit,
          validator: (value) =>
              errorHint != null && (value?.isEmpty ?? true) ? errorHint : null,
        ),
      );

  Widget _createPhoneAndConnectionPointRow(
    TextEditingController phoneController,
    TextEditingController tpController,
    TextEditingController lineController,
    TextEditingController pillarController,
  ) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 260.0,
            child: TextFormField(
              decoration: _outlinedDecoration('Телефон'),
              controller: phoneController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 15,
              validator: (phone) {
                final phoneRegExp = RegExp(r'^[\+\d\-\(\)]*$');
                return phoneRegExp.hasMatch(phone ?? '')
                    ? null
                    : 'Телефон содержит недопустимые символы';
              },
            ),
          ),
          const SizedBox(width: 36.0),
          SizedBox(
            width: 120.0,
            child: TextFormField(
              decoration: _outlinedDecoration('ТП'),
              controller: tpController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 6,
            ),
          ),
          const SizedBox(width: 6.0),
          SizedBox(
            width: 80.0,
            child: TextFormField(
              decoration: _outlinedDecoration('Линия'),
              controller: lineController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 3,
            ),
          ),
          const SizedBox(width: 6.0),
          SizedBox(
            width: 80.0,
            child: TextFormField(
              decoration: _outlinedDecoration('Опора'),
              controller: pillarController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 6,
            ),
          ),
        ],
      );

  Iterable<Widget> _createCounterRow(
      TextEditingController counterType,
      TextEditingController counterNumber,
      ValueNotifier<int?> checkQuarter,
      TextEditingController checkYear) sync* {
    bool hasNoCounterFilled() =>
        counterNumber.text.isEmpty || counterType.text.isEmpty;

    yield Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260.0,
          child: TextFormField(
            decoration: _outlinedDecoration('Тип ПУ'),
            controller: counterType,
            autovalidateMode: AutovalidateMode.always,
            maxLength: 17,
          ),
        ),
        const SizedBox(width: 36.0),
        SizedBox(
          width: 100.0,
          child: DropdownButtonFormField<int?>(
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 17.0),
              border: OutlineInputBorder(),
              labelText: 'Квартал ГП',
            ),
            autovalidateMode: AutovalidateMode.always,
            onChanged: (newValue) => checkQuarter.value = newValue,
            validator: (quarter) =>
                (quarter == null && checkYear.text.isNotEmpty) ||
                        (quarter != null && hasNoCounterFilled())
                    ? ""
                    : null,
            value: checkQuarter.value,
            items: dataState.availableCheckQuarters
                .map((q) => DropdownMenuItem(
                    value: q, child: Text(q?.romanGroup ?? '--')))
                .toList(),
          ),
        ),
        const SizedBox(width: 6.0),
        SizedBox(
          width: 100.0,
          child: TextFormField(
            decoration: _outlinedDecoration('Год ГП', alwaysFloating: true),
            controller: checkYear,
            autovalidateMode: AutovalidateMode.always,
            maxLength: 4,
            validator: (year) {
              if ((year!.isEmpty && checkQuarter.value != null) ||
                  (year.isNotEmpty && hasNoCounterFilled())) return '';

              final yearRegExp = RegExp(r'^\d{2}$|^(19|20)\d{2}$');
              if (year.isNotEmpty && !yearRegExp.hasMatch(year))
                return "Неверн. дата";

              return null;
            },
          ),
        ),
      ],
    );
    yield SizedBox(height: 6.0);
    yield SizedBox(
      width: 320.0,
      child: TextFormField(
        decoration: _outlinedDecoration('Номер ПУ', hasCounter: true),
        controller: counterNumber,
        autovalidateMode: AutovalidateMode.always,
        maxLength: 30,
      ),
    );
  }

  InputDecoration _outlinedDecoration(
    String label, {
    bool alwaysFloating = false,
    bool hasCounter = false,
  }) =>
      InputDecoration(
        floatingLabelBehavior: alwaysFloating
            ? FloatingLabelBehavior.always
            : FloatingLabelBehavior.auto,
        counter: hasCounter ? null : const SizedBox(),
        border: OutlineInputBorder(),
        labelText: label,
      );
}
