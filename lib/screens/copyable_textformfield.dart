import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin CopyableTextMixin {
  void handleKeyEvent(RawKeyEvent e, TextEditingController controller) {
    final isCopy =
        e.isControlPressed && e.isKeyPressed(LogicalKeyboardKey.keyC);
    final isPaste =
        e.isControlPressed && e.isKeyPressed(LogicalKeyboardKey.keyV);
    final isSelectAll =
        e.isControlPressed && e.isKeyPressed(LogicalKeyboardKey.keyA);
    final isCut = e.isControlPressed && e.isKeyPressed(LogicalKeyboardKey.keyX);
    final isMoveNext = e.isKeyPressed(LogicalKeyboardKey.arrowRight);
    final isMovePrev = e.isKeyPressed(LogicalKeyboardKey.arrowLeft);

    if (!controller.selection.isValid) {
      controller.selection = TextSelection.collapsed(offset: 0);
    }

    final text = controller.text;
    final sel = controller.selection;

    final selText = text.substring(sel.start, sel.end);

    if (isMoveNext && sel.end < text.length) {
      controller.selection =
          TextSelection.fromPosition(TextPosition(offset: sel.start + 1));
    } else if (isMovePrev && sel.start > 0) {
      controller.selection =
          TextSelection.fromPosition(TextPosition(offset: sel.start - 1));
    }

    if (isSelectAll && text.isNotEmpty) {
      controller.selection =
          TextSelection(baseOffset: 0, extentOffset: text.length);
    } else if (isCopy && selText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: controller.text));
    } else if (isPaste) {
      Clipboard.getData(Clipboard.kTextPlain).then((data) {
        if (data.text.isNotEmpty) {
          controller.text = text.substring(0, sel.start) +
              data.text +
              text.substring(sel.end);
        }
      });
    } else if (isCut && selText.isNotEmpty) {
      controller.text =
          text.substring(0, sel.baseOffset) + text.substring(sel.extentOffset);
    }
  }
}

class CopyableTextField extends StatefulWidget {
  final ValueChanged<String> onSubmitted;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final bool autofocus;

  const CopyableTextField({
    Key key,
    this.onSubmitted,
    this.controller,
    this.onChanged,
    this.autofocus = false,
  }) : super(key: key);

  @override
  _CopyableTextFieldState createState() => _CopyableTextFieldState();
}

class _CopyableTextFieldState extends State<CopyableTextField>
    with CopyableTextMixin {
  TextEditingController controller;
  FocusNode _focus;

  @override
  void initState() {
    controller = widget.controller ?? TextEditingController();
    _focus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) controller.dispose();

    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _focus,
      onKey: (RawKeyEvent e) => handleKeyEvent(e, controller),
      child: TextField(
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        controller: controller,
      ),
    );
  }
}

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

class _CopyableTextFormFieldState extends State<CopyableTextFormField>
    with CopyableTextMixin {
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
        onKey: (RawKeyEvent e) => handleKeyEvent(e, widget.controller),
        child: TextFormField(
          controller: widget.controller,
          autovalidateMode: widget.autovalidateMode,
          maxLength: widget.maxLength,
          validator: widget.validator,
        ),
      );
}
