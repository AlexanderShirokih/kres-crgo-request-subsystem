import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/models/connection_point.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';

/// Describes single item of request entity
class RequestItemView extends StatelessWidget {
  final int position;
  final Request request;

  final bool isHighlighted;

  // true - selected, false - not selected, null - not in selection mode
  final bool? isSelected;

  // A group (mark) attachment
  final int groupIndex;

  final int defaultGroupIndex;

  final void Function(bool) onChanged;

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
                vertical: 8.0,
                horizontal: 6.0,
              ),
              child: _createRequestContent(context),
            ),
            Positioned(
              right: 4.0,
              top: 4.0,
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

  Widget _createRequestContent(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSelected != null)
                Checkbox(
                    value: isSelected,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onChanged(newValue);
                      }
                    }),
              // First column
              Text(position.toString()),
              const SizedBox(width: 16.0),
              SizedBox(
                width: 72.0,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.accountId?.toString().padLeft(6, '0') ?? "--",
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 20.0),
                    ),
                    const SizedBox(height: 8.0),
                    Text(request.requestType?.shortName ?? "--"),
                  ],
                ),
              ),
              // Second column
              const SizedBox(width: 12.0),
              SizedBox(
                width: 360.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.name, style: const TextStyle(fontSize: 20.0)),
                    const SizedBox(height: 6.0),
                    Text(
                      request.address,
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      request.reason ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              // Third column
              const SizedBox(width: 12.0),
              SizedBox(
                width: 320.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 220.0,
                          child: Text(
                            request.counter?.mainInfo ?? 'ПУ отсутств.',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          request.counter?.checkInfo ?? '',
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    _printConnectionPoint(request.connectionPoint),
                    const SizedBox(height: 10.0),
                    _printPhone(request.phoneNumber),
                  ],
                ),
              )
            ],
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text(
              request.additionalInfo ?? '',
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      );

  Widget _printPhone(String? phone) {
    if (phone == null) {
      return const SizedBox();
    }

    return Row(
      children: [
        const Icon(Icons.phone, size: 20.0),
        const SizedBox(width: 4.0),
        Text(phone, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _printConnectionPoint(ConnectionPoint? connectionPoint) {
    Iterable<Widget> printConnectionPoint0() sync* {
      if (connectionPoint == null || connectionPoint.isEmpty) {
        yield const Text('--');
        return;
      }

      if (connectionPoint.tp != null) {
        yield Text('ТП: ${connectionPoint.tp ?? '--'}');
        yield const SizedBox(width: 8);
      }
      if (connectionPoint.line != null) {
        yield Text('Ф: ${connectionPoint.line ?? '--'}');
        yield const SizedBox(width: 8);
      }
      if (connectionPoint.pillar != null) {
        yield Text('оп: ${connectionPoint.pillar ?? '--'}');
        yield const SizedBox(width: 8);
      }
    }

    return Row(
      children: [
        const FaIcon(FontAwesomeIcons.plug, size: 16.0),
        const SizedBox(width: 12.0),
        ...printConnectionPoint0(),
      ],
    );
  }
}

typedef GroupChangeCallback = void Function(int newGroup);

class _MarkWidget extends StatelessWidget {
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
  Widget build(BuildContext context) => GestureDetector(
        onSecondaryTap: () => changeCallback(defaultGroupIndex),
        child: InkWell(
          child: IconButton(
            padding: const EdgeInsets.symmetric(
              horizontal: 6.0,
              vertical: 8.0,
            ),
            onPressed: () => showDialog<int>(
              context: context,
              builder: (_) => _ChooseColorDialog(groupIndex),
            ).then((selectedGroup) {
              if (selectedGroup != null) {
                changeCallback(selectedGroup);
              }
            }),
            icon: groupIndex == 0
                ? const FaIcon(
                    FontAwesomeIcons.bookmark,
                    size: 16.0,
                    color: Colors.black,
                  )
                : FaIcon(
                    FontAwesomeIcons.solidBookmark,
                    size: 16.0,
                    color: _getMarkColor(groupIndex),
                  ),
          ),
        ),
      );
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
      content: SizedBox(
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
                              color: Theme.of(context).colorScheme.secondary,
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
