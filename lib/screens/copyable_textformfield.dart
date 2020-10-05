import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyableTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  final FormFieldValidator<String> validator;
  final AutovalidateMode autovalidateMode;

  const CopyableTextFormField({
    Key key,
    this.controller,
    this.maxLength,
    this.validator,
    this.autovalidateMode,
  }) : super(key: key);

  @override
  _CopyableTextFormFieldState createState() => _CopyableTextFormFieldState();
}

class _CopyableTextFormFieldState extends State<CopyableTextFormField> {
  FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    _focus.dispose();
  }

  @override
  Widget build(BuildContext context) => RawKeyboardListener(
        focusNode: _focus,
        onKey: (RawKeyEvent e) {
          final isCopy =
              e.isControlPressed && e.isKeyPressed(LogicalKeyboardKey.keyC);
          final isPaste =
              e.isControlPressed && e.isKeyPressed(LogicalKeyboardKey.keyV);
          final isSelectAll =
              e.isControlPressed && e.isKeyPressed(LogicalKeyboardKey.keyA);
          final isCut =
              e.isControlPressed && e.isKeyPressed(LogicalKeyboardKey.keyX);
          final isMoveNext = e.isKeyPressed(LogicalKeyboardKey.arrowRight);
          final isMovePrev = e.isKeyPressed(LogicalKeyboardKey.arrowLeft);

          if (!widget.controller.selection.isValid) {
            widget.controller.selection = TextSelection.collapsed(offset: 0);
          }

          final text = widget.controller.text;
          final sel = widget.controller.selection;

          final selText = text.substring(sel.start, sel.end);

          if (isMoveNext && sel.end < text.length) {
            widget.controller.selection =
                TextSelection.fromPosition(TextPosition(offset: sel.start + 1));
          } else if (isMovePrev && sel.start > 0) {
            widget.controller.selection =
                TextSelection.fromPosition(TextPosition(offset: sel.start - 1));
          }

          if (isSelectAll && text.isNotEmpty) {
            widget.controller.selection =
                TextSelection(baseOffset: 0, extentOffset: text.length);
          } else if (isCopy && selText.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: widget.controller.text));
          } else if (isPaste) {
            Clipboard.getData(Clipboard.kTextPlain).then((data) {
              if (data.text.isNotEmpty) {
                widget.controller.text = text.substring(0, sel.start) +
                    data.text +
                    text.substring(sel.end);
              }
            });
          } else if (isCut && selText.isNotEmpty) {
            widget.controller.text = text.substring(0, sel.baseOffset) +
                text.substring(sel.extentOffset);
          }
        },
        child: TextFormField(
          controller: widget.controller,
          autovalidateMode: widget.autovalidateMode,
          maxLength: widget.maxLength,
          validator: widget.validator,
        ),
      );
}
