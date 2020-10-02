import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StartupScreenButton extends StatelessWidget {
  final String label;
  final IconData iconData;
  final void Function() onPressed;

  const StartupScreenButton({
    @required this.label,
    @required this.iconData,
    @required this.onPressed,
  })  : assert(label != null),
        assert(iconData != null),
        assert(onPressed != null);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 260.0, minHeight: 48.0),
          child: RaisedButton.icon(
            color: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide.none,
            ),
            elevation: 5.0,
            onPressed: onPressed,
            icon: FaIcon(
              iconData,
              color: Theme.of(context).primaryTextTheme.bodyText2.color,
            ),
            label: Text(
              label,
              style: Theme.of(context).primaryTextTheme.bodyText2,
            ),
          ),
        ),
      );
}
