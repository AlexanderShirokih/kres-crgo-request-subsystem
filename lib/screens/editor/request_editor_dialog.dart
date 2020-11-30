import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kres_requests2/models/account_info.dart';
import 'package:kres_requests2/models/address.dart';
import 'package:kres_requests2/models/counting_point.dart';
import 'package:kres_requests2/models/request.dart';
import 'package:kres_requests2/repo/counter_types_repository.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/repo/request_types_repository.dart';
import 'package:kres_requests2/repo/street_repository.dart';

import '../copyable_textformfield.dart';
import '../../utils/utils.dart';

class RequestEditorDialog extends StatefulWidget {
  final Request editingRequest;
  final StreetRepository streetRepository;
  final CounterTypesRepository counterTypesRepository;
  final RequestTypeRepository requestTypeRepository;

  RequestEditorDialog({
    @required RepositoryModule repositoryModule,
    this.editingRequest,
  })  : streetRepository = repositoryModule.getStreetRepository(),
        counterTypesRepository = repositoryModule.getCounterTypesRepository(),
        requestTypeRepository = repositoryModule.getRequestTypeRepository();

  @override
  _RequestEditorDialogState createState() =>
      _RequestEditorDialogState(editingRequest);
}

class _RequestEditorDialogState extends State<RequestEditorDialog> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _lsController;
  TextEditingController _homeController;
  TextEditingController _apartmentController;
  TextEditingController _nameController;
  TextEditingController _counterNumberController;
  TextEditingController _additionalController;
  TextEditingController _tpController;
  TextEditingController _feederController;
  TextEditingController _pillarController;
  TextEditingController _phoneController;

  final Request _request;

  CounterType _counterType;
  RequestType _requestType;
  Street _street;
  int _checkQuarter;
  int _checkYear;

  bool _isValid;
  bool _isNew;

  _RequestEditorDialogState(this._request)
      : _isNew = _request == null,
        _isValid = _request != null;

  @override
  void initState() {
    super.initState();
    _requestType = _request?.requestType;
    _street = _request?.accountInfo?.street;
    _counterType = _request?.countingPoint?.counterType;
    _checkQuarter = _request?.countingPoint?.checkQuarter;
    _checkYear = _request?.countingPoint?.checkYear;

    _lsController = TextEditingController(
        text: _request?.accountInfo?.baseId?.toString()?.padLeft(6, '0') ?? "");
    _homeController =
        TextEditingController(text: _request?.accountInfo?.homeNumber);
    _apartmentController =
        TextEditingController(text: _request?.accountInfo?.apartmentNumber);
    _phoneController =
        TextEditingController(text: _request?.accountInfo?.phoneNumber);
    _nameController = TextEditingController(text: _request?.accountInfo?.name);
    _counterNumberController =
        TextEditingController(text: _request?.countingPoint?.counterNumber);
    _tpController =
        TextEditingController(text: _request?.countingPoint?.tpName);
    _feederController = TextEditingController(
        text: _request?.countingPoint?.feederNumber?.toString());
    _pillarController =
        TextEditingController(text: _request?.countingPoint?.pillarNumber);

    _additionalController = TextEditingController(text: _request?.additional);
  }

  @override
  void dispose() {
    super.dispose();
    _lsController.dispose();
    _homeController.dispose();
    _apartmentController.dispose();
    _nameController.dispose();
    _counterNumberController.dispose();
    _additionalController.dispose();
    _tpController.dispose();
    _feederController.dispose();
    _pillarController.dispose();
    _phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actionsPadding: const EdgeInsets.only(bottom: 16.0, right: 24.0),
      title: Text(
        _isNew
            ? 'Создание заявки'
            : 'Редактирование заявки | Л/С №${_request?.accountInfo?.baseId?.toString()?.padLeft(6, '0') ?? "--"}',
        textAlign: TextAlign.center,
      ),
      content: Container(
        height: 580.0,
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
                    textBaseline: TextBaseline.alphabetic,
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
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("Тип заявки: "),
                      const SizedBox(width: 8.0),
                      _buildRequestTypeSelector(),
                    ],
                  ),
                ],
              ),
              ..._createInputField("ФИО: ", "Введите ФИО", _nameController),
              ..._createAddressField(),
              ..._createCounterField(),
              ..._createCountingPointField(),
              ..._createInputField(
                  "Дополнительно: ", null, _additionalController,
                  limit: 56),
            ],
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
            onPressed: () => Navigator.pop(
              context,
              Request(
                id: _request?.id,
                reason: _request?.reason,
                requestType: _requestType,
                additional: _additionalController.text,
                accountInfo: AccountInfo(
                  baseId: int.parse(_sanitize(_lsController.text)),
                  name: _sanitize(_nameController.text),
                  street: _street,
                  homeNumber: _sanitize(_homeController.text),
                  apartmentNumber: _sanitize(_apartmentController.text),
                  phoneNumber: _sanitize(_phoneController.text),
                ),
                countingPoint: _counterType == null
                    ? null
                    : CountingPoint(
                        checkQuarter: _checkQuarter,
                        checkYear: _checkYear,
                        counterNumber: _counterNumberController.text,
                        counterType: _counterType,
                        feederNumber: int.parse(_feederController.text),
                        pillarNumber: _pillarController.text,
                        tpName: _tpController.text,
                      ),
              ),
            ),
            child: Text("Сохранить"),
          ),
      ],
    );
  }

  String _sanitize(String value) {
    return value.replaceAll(RegExp(r"[\n\r]"), "");
  }

  Iterable<Widget> _createAddressField() sync* {
    yield SizedBox(height: 24);
    yield Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 130.0,
            ),
            child: Text('Улица: '),
          ),
          _buildStreetSelector(),
          const SizedBox(width: 24.0),
          Text('Дом: '),
          const SizedBox(width: 6.0),
          SizedBox(
            width: 60.0,
            child: CopyableTextFormField(
              controller: _homeController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 6,
              validator: (value) => value.isEmpty ? '' : null,
            ),
          ),
          const SizedBox(width: 24.0),
          Text('Кв.: '),
          const SizedBox(width: 6.0),
          SizedBox(
            width: 60.0,
            child: CopyableTextFormField(
              controller: _apartmentController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 6,
            ),
          ),
        ]);
  }

  Iterable<Widget> _createCountingPointField() sync* {
    yield SizedBox(height: 24);
    yield Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 130.0,
            ),
            child: Text('Точка учёта: '),
          ),
          const SizedBox(width: 24.0),
          Text('ТП : '),
          const SizedBox(width: 6.0),
          SizedBox(
            width: 80.0,
            child: CopyableTextFormField(
              controller: _tpController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 7,
            ),
          ),
          const SizedBox(width: 24.0),
          Text('Фидер: '),
          const SizedBox(width: 6.0),
          SizedBox(
            width: 60.0,
            child: CopyableTextFormField(
              controller: _feederController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 2,
            ),
          ),
          const SizedBox(width: 24.0),
          Text('Опора: '),
          const SizedBox(width: 6.0),
          SizedBox(
            width: 60.0,
            child: CopyableTextFormField(
              controller: _pillarController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 5,
            ),
          ),
        ]);
  }

  Iterable<Widget> _createCounterField() sync* {
    yield SizedBox(height: 24);
    yield Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 130.0,
            ),
            child: Text('Прибор учёта: '),
          ),
          _buildCounterTypeSelector(),
          const SizedBox(width: 24.0),
          Text('№ : '),
          const SizedBox(width: 6.0),
          SizedBox(
            width: 160.0,
            child: CopyableTextFormField(
              controller: _counterNumberController,
              autovalidateMode: AutovalidateMode.always,
              maxLength: 24,
              validator: (value) =>
                  value.isEmpty && _counterType != null ? '' : null,
            ),
          ),
          const SizedBox(width: 24.0),
          Text('Поверка.: '),
          const SizedBox(width: 6.0),
          _buildQuarter(),
          const SizedBox(width: 6.0),
          _buildCheckYearSelector(),
        ]);
  }

  Iterable<Widget> _createInputField(
    String label,
    String errorHint,
    TextEditingController controller, {
    int limit,
  }) sync* {
    yield SizedBox(height: 24);
    yield Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 130.0,
          ),
          child: Text(label),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: CopyableTextFormField(
            controller: controller,
            autovalidateMode: AutovalidateMode.always,
            maxLength: limit,
            validator: (value) =>
                errorHint != null && value.isEmpty ? errorHint : null,
          ),
        )
      ],
    );
  }

  Widget _buildQuarter() => _buildDropdown<int>(
        width: 60.0,
        valueBuilder: (e) => quarterToString(e),
        futureBuilder: () => Future.value([1, 2, 3, 4]),
        validator: (val) => val != null && _counterType != null,
        valueProvider: () => _checkQuarter,
        onChanged: (newValue) => setState(() {
          _checkQuarter = newValue;
        }),
      );

  Widget _buildCheckYearSelector() => _buildDropdown<int>(
        width: 80.0,
        valueBuilder: (e) => e.toString(),
        futureBuilder: () => Future.value(_getYears().toList()),
        valueProvider: () => _checkYear,
        validator: (val) => false,
        //val != null && _counterType == null,
        onChanged: (newValue) => setState(() {
          _checkYear = newValue;
        }),
      );

  Iterable<int> _getYears() sync* {
    final currentYear = DateTime.now().year;
    for (int year = currentYear; year >= 1980; year--) yield year;
  }

  Widget _buildStreetSelector() => _buildDropdown<Street>(
        errorText: 'Выберите улицу',
        width: 200.0,
        valueBuilder: (e) => e.name,
        futureBuilder: () => widget.streetRepository.getAll(),
        valueProvider: () => _street,
        onChanged: (newValue) => setState(() {
          _street = newValue;
        }),
      );

  Widget _buildCounterTypeSelector() => _buildDropdown<CounterType>(
        width: 100.0,
        valueBuilder: (e) => e.name,
        futureBuilder: () => widget.counterTypesRepository.getAll(),
        valueProvider: () => _counterType,
        onChanged: (newValue) => setState(() {
          _counterType = newValue;
        }),
      );

  Widget _buildRequestTypeSelector() => _buildDropdown<RequestType>(
        errorText: 'Тип не выбран',
        width: 164.0,
        valueBuilder: (e) => e.shortName,
        futureBuilder: () => widget.requestTypeRepository.getAll(),
        valueProvider: () => _requestType,
        onChanged: (newValue) => setState(() {
          _requestType = newValue;
        }),
      );

  Widget _buildDropdown<T>({
    String errorText,
    double width,
    String Function(T) valueBuilder,
    Future<List<T>> Function() futureBuilder,
    T Function() valueProvider,
    bool Function(T) validator,
    void Function(T) onChanged,
  }) =>
      FutureBuilder<List<T>>(
        future: futureBuilder(),
        builder: (context, snap) {
          return snap.hasData
              ? SizedBox(
                  width: width,
                  child: DropdownButtonFormField<T>(
                    autovalidateMode: AutovalidateMode.always,
                    validator: (value) => value == null &&
                            (errorText != null ||
                                (validator != null && !validator(value)))
                        ? errorText
                        : null,
                    value: valueProvider(),
                    items:
                        (errorText == null ? [null, ...snap.data] : snap.data)
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e == null ? '' : valueBuilder(e),
                                    overflow: TextOverflow.fade),
                              ),
                            )
                            .toList(),
                    onChanged: (newValue) => onChanged(newValue),
                  ),
                )
              : SizedBox(
                  width: 18.0,
                  height: 18.0,
                  child: CircularProgressIndicator(),
                );
        },
      );
}
