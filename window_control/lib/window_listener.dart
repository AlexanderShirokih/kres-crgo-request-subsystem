import 'package:flutter/widgets.dart';
import 'package:window_control/window_control.dart';

class WindowListener extends StatefulWidget {
  final Future<bool> Function() onWindowClosing;
  final Widget child;

  const WindowListener(
      {Key key, @required this.onWindowClosing, @required this.child})
      : assert(child != null),
        assert(onWindowClosing != null),
        super(key: key);

  @override
  _WindowListenerState createState() => _WindowListenerState();
}

class _WindowListenerState extends State<WindowListener> {
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
