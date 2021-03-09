import 'package:flutter/material.dart';

/// Button with trash icon which is highlighted when mouse hovered.
class DeleteButton extends StatefulWidget {
  /// Callback called when button is pressed
  final VoidCallback onPressed;

  const DeleteButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  _DeleteButtonState createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton> {
  bool _isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHighlighted = true;
      }),
      onExit: (_) => setState(() {
        _isHighlighted = false;
      }),
      child: IconButton(
        icon: Icon(
          Icons.delete,
          color: _isHighlighted ? Theme.of(context).errorColor : null,
        ),
        onPressed: _isHighlighted ? widget.onPressed : null,
      ),
    );
  }
}
