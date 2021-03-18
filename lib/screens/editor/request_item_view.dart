import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// Describes single item of request entity
class RequestItemView extends StatelessWidget {
  final int position;
  final RequestEntity request;

  final bool isHighlighted;

  // true - selected, false - not selected, null - not in selection mode
  final bool? isSelected;

  // A group (mark) attachment
  final int groupIndex;

  final int defaultGroupIndex;

  final void Function(bool?) onChanged;

  final GroupChangeCallback groupChangeCallback;

  const RequestItemView({
    required this.position,
    required this.isSelected,
    required this.isHighlighted,
    required this.request,
    required this.onChanged,
    required this.groupChangeCallback,
    required this.groupIndex,
    required this.defaultGroupIndex,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (isSelected != null) onChanged(!isSelected!);
      },
      child: Card(
        color: isHighlighted ? Colors.yellow : Colors.white,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 8.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isSelected != null)
                    Checkbox(value: isSelected, onChanged: onChanged),
                  Container(
                    width: 24.0,
                    child: Text(position.toString()),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.accountId?.toString().padLeft(6, '0') ?? "--",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 20.0,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(request.requestType?.shortName ?? "--"),
                    ],
                  ),
                  const SizedBox(width: 12.0),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 380.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.name,
                          style: TextStyle(
                            fontSize: 22.0,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          request.address,
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        ..._printRequestReason(request, context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24.0),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 380.0,
                      maxWidth: 420.0,
                    ),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.counterInfo!,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            request.additionalInfo!,
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              left: 4.0,
              bottom: 4.0,
              child: _MarkWidget(
                groupIndex: groupIndex,
                defaultGroupIndex: defaultGroupIndex,
                changeCallback: groupChangeCallback,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _printRequestReason(
    RequestEntity request,
    BuildContext context,
  ) {
    if (request.reason != null && request.reason!.isNotEmpty) {
      return [
        const SizedBox(height: 16.0),
        Text(
          request.reason!,
          style: Theme.of(context).textTheme.caption!.copyWith(fontSize: 16.0),
        ),
      ];
    }
    return <Widget>[];
  }
}

typedef GroupChangeCallback = void Function(int newGroup);

class _MarkWidget extends StatefulWidget {
  final GroupChangeCallback changeCallback;
  final int groupIndex;
  final int defaultGroupIndex;

  const _MarkWidget({
    Key? key,
    required this.groupIndex,
    required this.defaultGroupIndex,
    required this.changeCallback,
  }) : super(key: key);

  @override
  __MarkWidgetState createState() => __MarkWidgetState();
}

const _markColors = [
  Colors.white,
  Colors.green,
  Colors.red,
  Colors.purple,
  Colors.orange,
  Colors.indigo,
  Colors.tealAccent,
];

Color _getMarkColor(int groupId) => _markColors[groupId];

class __MarkWidgetState extends State<_MarkWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onHover: (_) => setState(() {
          _isHovered = true;
        }),
        onExit: (_) => setState(() {
          _isHovered = false;
        }),
        child: _isHovered || widget.groupIndex != 0
            ? GestureDetector(
                onSecondaryTap: () =>
                    widget.changeCallback(widget.defaultGroupIndex),
                child: InkWell(
                  child: IconButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 8.0,
                    ),
                    onPressed: () => showDialog<int>(
                      context: context,
                      builder: (_) => _ChooseColorDialog(widget.groupIndex),
                    ).then((selectedGroup) {
                      if (selectedGroup != null) {
                        widget.changeCallback(selectedGroup);
                      }
                    }),
                    icon: widget.groupIndex == 0
                        ? FaIcon(
                            FontAwesomeIcons.bookmark,
                            size: 16.0,
                            color: Colors.black,
                          )
                        : FaIcon(
                            FontAwesomeIcons.solidBookmark,
                            size: 16.0,
                            color: _getMarkColor(widget.groupIndex),
                          ),
                  ),
                ),
              )
            : const SizedBox(
                width: 28.0,
                height: 34.0,
              ),
      );
}

final _fullGroupNames = [
  'Белый',
  'Зелёный',
  'Красный',
  'Фиолетовый',
  'Оранжевый',
  'Синий',
  'Бирюзовый'
];

class _ChooseColorDialog extends StatelessWidget {
  final int initialGroup;

  const _ChooseColorDialog(this.initialGroup);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 60.0,
        child: Row(
          children: List.generate(
            _markColors.length,
            (index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () => Navigator.pop(context, index),
                child: Tooltip(
                  message: _fullGroupNames[index],
                  child: Container(
                    decoration: BoxDecoration(
                      border: initialGroup == index
                          ? Border.all(
                              color: Theme.of(context).accentColor,
                              width: 4.0,
                            )
                          : Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                      shape: BoxShape.circle,
                      color: _getMarkColor(index),
                    ),
                    width: 48.0,
                    height: 48.0,
                  ),
                ),
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }
}
