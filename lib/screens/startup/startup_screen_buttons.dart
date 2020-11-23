import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// Common container for startup buttons
class StartupScreenButtonContainer extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const StartupScreenButtonContainer({
    @required this.onPressed,
    @required this.child,
  })  : assert(child != null),
        assert(onPressed != null);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 220.0, minHeight: 240.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 2.0,
                  offset: Offset(3.0, 3.0),
                )
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              hoverColor: Colors.transparent,
              onTap: onPressed,
              child: child,
            ),
          ),
        ),
      );
}

/// Content of startup button that shows text and description
class SimpleTextStartupTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;

  const SimpleTextStartupTile({
    Key key,
    @required this.title,
    @required this.description,
    @required this.iconData,
  })  : assert(title != null),
        assert(description != null),
        assert(iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LayoutBuilder(
              builder: (context, constraint) => FaIcon(
                iconData,
                size: constraint.biggest.shortestSide,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 18.0),
            SizedBox(
              height: 52.0,
              child: Text(
                description,
                overflow: TextOverflow.fade,
                softWrap: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Displays request set
class RequestSetDescriptionTile extends StatelessWidget {
  final String name;
  final DateTime targetDate;

  const RequestSetDescriptionTile({
    Key key,
    @required this.name,
    @required this.targetDate,
  })  : assert(name != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraint) => FaIcon(
                  FontAwesomeIcons.fileAlt,
                  size: constraint.biggest.shortestSide,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.headline6,
                overflow: TextOverflow.fade,
              ),
              const SizedBox(height: 18.0),
              Text(
                _formattedDate(),
                style: Theme.of(context).textTheme.bodyText2,
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
      ],
    );
  }

  static DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  String _formattedDate() {
    if (targetDate == null) return '??';

    final now = DateTime.now();

    if (now.year == targetDate.year && now.month == targetDate.month)
      switch (now.day - targetDate.day) {
        case -2:
          return 'На после завтра';
        case -1:
          return 'На завтра';
        case 0:
          return 'На сегодня';
        case 1:
          return 'На вчера';
      }

    return 'На ${_dateFormat.format(targetDate)}';
  }
}
