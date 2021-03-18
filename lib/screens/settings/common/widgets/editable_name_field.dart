import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/validators/string_validator.dart';

/// Text field which is editable only when edit button has pressed.
/// [onChanged] callback called when user clicks done button or hits enter.
class EditableNameField extends StatefulWidget {
  /// Initial field text
  final String value;

  final StringValidator validator;

  /// Called when text in the text field was updated
  final Function(String) onChanged;

  const EditableNameField({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.validator,
  }) : super(key: key);

  @override
  _EditableNameFieldState createState() => _EditableNameFieldState();
}

class _EditableNameFieldState extends State<EditableNameField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.value.isEmpty;
    _focusNode = FocusNode();
    _controller = TextEditingController(text: widget.value);
    if (_isEditing) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onEditingDone() => setState(
        () {
          _isEditing = false;
          if (widget.value != _controller.text) {
            widget.onChanged(_controller.text);
          }
        },
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              readOnly: !_isEditing,
              autovalidateMode: AutovalidateMode.always,
              maxLines: 1,
              maxLength: widget.validator.maxLength,
              autofocus: false,
              validator: (value) {
                final errors = widget.validator.validate(value!);
                return errors.isEmpty ? null : errors.first;
              },
              onEditingComplete: _onEditingDone,
              decoration: InputDecoration(
                border: InputBorder.none,
                counter: SizedBox(),
              ),
              style: Theme.of(context).dataTableTheme.dataTextStyle,
            ),
          ),
          if (_isEditing)
            IconButton(
              icon: FaIcon(FontAwesomeIcons.check),
              onPressed: _onEditingDone,
            )
          else
            IconButton(
              icon: FaIcon(FontAwesomeIcons.edit),
              onPressed: () => setState(
                () {
                  _focusNode.requestFocus();
                  _isEditing = true;
                },
              ),
            ),
          const SizedBox(width: 24.0),
        ],
      ),
    );
  }
}
