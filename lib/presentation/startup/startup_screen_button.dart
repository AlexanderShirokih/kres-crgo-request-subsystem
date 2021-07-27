import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

/// Content of startup button that shows text and description
class TextStartupTile extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;

  const TextStartupTile({
    Key? key,
    required this.title,
    required this.description,
    required this.iconData,
  }) : super(key: key);

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

/// Content of startup button that shows text and description
class ShowMoreTile extends StatelessWidget {
  const ShowMoreTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Center(
          child: FaIcon(
            FontAwesomeIcons.ellipsisH,
            size: 54,
          ),
        ),
        Text(
          'Показать ещё',
          style: Theme.of(context).textTheme.headline6,
        ),
      ],
    );
  }
}

/// Show the recent document item
class RecentDocumentTile extends StatelessWidget {
  final String name;
  final DateTime updateDate;

  const RecentDocumentTile({
    Key? key,
    required this.name,
    required this.updateDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Center(
            child: FaIcon(FontAwesomeIcons.solidFileAlt, size: 54),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const FaIcon(FontAwesomeIcons.solidCalendarAlt),
                  const SizedBox(width: 4.0),
                  Text(
                    'Изменено:\n${_formattedDate()}',
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  static final DateFormat _timeFormat = DateFormat.Hm();

  String _formattedDate() {
    String time() => _timeFormat.format(updateDate);
    final now = DateTime.now();
    if (now.year == updateDate.year && now.month == updateDate.month) {
      switch (now.day - updateDate.day) {
        case 0:
          return 'Сегодня, в ${time()}';
        case 1:
          return 'Вчера, в ${time()}';
      }
    }

    return _dateFormat.format(updateDate);
  }
}

/// Common container for startup buttons
class StartupScreenButtonContainer extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  const StartupScreenButtonContainer({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 220.0, minHeight: 240.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
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
