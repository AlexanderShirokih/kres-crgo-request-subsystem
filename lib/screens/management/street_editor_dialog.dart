import 'package:flutter/material.dart';
import 'package:kres_requests2/models/address.dart';
import 'package:kres_requests2/repo/districts_repository.dart';
import 'package:kres_requests2/screens/common.dart';

/// Dialog for editing [Street] items
class StreetEditorDialog extends StatefulWidget {
  final DistrictRepository districtRepository;
  final Street street;
  final bool isNew;

  const StreetEditorDialog(this.street, this.districtRepository)
      : assert(districtRepository != null),
        isNew = street == null;

  @override
  _StreetEditorDialogState createState() => _StreetEditorDialogState();
}

class _StreetEditorDialogState extends State<StreetEditorDialog> {
  static const _kLabelsWidth = 160.0;

  final _formKey = GlobalKey<FormState>();

  List<District> _fetchedDistricts;
  TextEditingController _nameController;
  District _district;
  bool _isValid = true;

  @override
  void initState() {
    widget.districtRepository.getAll().then((value) {
      if (mounted) {
        setState(() {
          _fetchedDistricts = value + [null];
        });
      }
    });

    _isValid = !widget.isNew;
    _district = widget.street?.district;
    _nameController = TextEditingController(text: widget.street?.name ?? '');
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
                  Street(
                    name: _nameController.text,
                    district: _district,
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
            _buildDistrictField(),
          ],
        ),
      );

  Widget _buildDistrictField() => Row(
        children: [
          buildFixedWidthText('Район: ', _kLabelsWidth),
          SizedBox(
            width: 140.0,
            child: DropdownButtonFormField<District>(
              value: _district,
              items: _fetchedDistricts == null
                  ? null
                  : _fetchedDistricts
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e?.name ?? '--'),
                        ),
                      )
                      .toList(),
              onChanged: (newDistrict) => setState(() {
                _district = newDistrict;
              }),
            ),
          )
        ],
      );

  Widget _buildNameField() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          buildFixedWidthText('Название улицы: ', _kLabelsWidth),
          SizedBox(
            width: 300.0,
            child: TextFormField(
              controller: _nameController,
              autovalidateMode: AutovalidateMode.always,
              validator: (text) => text == null || text.isEmpty ? '' : null,
              maxLength: 80,
            ),
          )
        ],
      );
}
