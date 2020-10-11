import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:window_control/window_control.dart';

class TitleBarBindings {
  static final _instance = TitleBarBindings();

  static TitleBarBindings get instance => _instance;

  Future<bool> Function() onAppClosing;

  void registerClosingCallback(Future<bool> Function() onAppClosing) {
    print("Register callback");
    this.onAppClosing = onAppClosing;
  }

  void unregisterClosingCallback() {
    print("Unregister callback");
    onAppClosing = null;
  }
}

class TitleBar extends StatelessWidget {
  static const _kTitleBarHeight = 34.0;

  final Widget child;

  const TitleBar({this.child}) : assert(child != null);

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTapDown: (_) => WindowControl.startDrag(),
              onDoubleTap: () => WindowControl.toggleMaxWindow(),
              child: Container(
                width: double.maxFinite,
                height: TitleBar._kTitleBarHeight,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _TitleBarButton(
                      icon: FontAwesomeIcons.windowMinimize,
                      hoverColor: Colors.blue[500],
                      onPressed: () => WindowControl.minWindow(),
                    ),
                    _TitleBarButton(
                      icon: FontAwesomeIcons.windowMaximize,
                      hoverColor: Colors.blue[500],
                      onPressed: () => WindowControl.toggleMaxWindow(),
                    ),
                    _TitleBarButton(
                      icon: FontAwesomeIcons.times,
                      hoverColor: Colors.red[300],
                      onPressed: () {
                        final callback = TitleBarBindings.instance.onAppClosing;
                        print("CALLBACK is ${callback != null}");
                        if (callback != null) {
                          callback().then((shouldClose) {
                            print("SHOULD CLOSE = $shouldClose");
                            if (shouldClose) {
                              WindowControl.closeWindow();
                            }
                          });
                        } else
                          WindowControl.closeWindow();
                      },
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
}

class _TitleBarButton extends StatefulWidget {
  final IconData icon;
  final Color hoverColor;
  final VoidCallback onPressed;

  const _TitleBarButton({Key key, this.icon, this.hoverColor, this.onPressed})
      : super(key: key);

  @override
  __TitleBarButtonState createState() => __TitleBarButtonState();
}

class __TitleBarButtonState extends State<_TitleBarButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) => Material(
        child: InkWell(
          onTap: widget.onPressed,
          hoverColor: widget.hoverColor,
          onHover: (isHover) => setState(() {
            this.isHover = isHover;
          }),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 18.0),
            child: FaIcon(
              widget.icon,
              size: 16.0,
              color: isHover ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
}
