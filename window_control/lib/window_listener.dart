import 'package:flutter/widgets.dart';
import 'package:window_control/window_control.dart';

/// Widget that listens window events
class WindowStateListener extends StatefulWidget {
  final Future<bool> Function() onWindowClosing;
  final Widget child;

  const WindowStateListener({
    Key? key,
    required this.onWindowClosing,
    required this.child,
  }) : super(key: key);

  @override
  _WindowListenerState createState() => _WindowListenerState();
}

class _WindowListenerState extends State<WindowStateListener> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WindowControl.instance.addOnWindowClosingCallback(widget.onWindowClosing);
  }

  @override
  void dispose() {
    super.dispose();
    WindowControl.instance
        .removeOnWindowClosingCallback(widget.onWindowClosing);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
