import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kres_requests2/domain/models.dart';

import 'worksheet_card.dart';

/// Shows a group of checkable worksheet cards
class WorksheetCardGroup extends StatefulWidget {
  /// List of all not empty worksheets
  final List<Worksheet> worksheets;

  final void Function(List<Worksheet>) onStatusChanged;

  const WorksheetCardGroup({
    required this.worksheets,
    required this.onStatusChanged,
  });

  @override
  _WorksheetCardGroupState createState() => _WorksheetCardGroupState();
}

class _WorksheetCardGroupState extends State<WorksheetCardGroup> {
  static const _tileMaxWidth = 500.0;

  late Map<Worksheet, bool> _checkedCards;

  @override
  void initState() {
    super.initState();
    _checkedCards = Map.fromIterable(
      widget.worksheets,
      key: (k) => k,
      value: (_) => true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-0.8, -0.8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = max(1, constraints.maxWidth ~/ _tileMaxWidth);
          return crossAxisCount > 1 && widget.worksheets.length > 1
              ? GridView.count(
                  crossAxisCount: crossAxisCount,
                  children: _buildChildren(context),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: _buildChildren(context),
                  ),
                );
        },
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) => widget.worksheets
      .map(
        (worksheet) => ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _tileMaxWidth,
          ),
          child: WorksheetCard(
            worksheet: worksheet,
            isSelected: _checkedCards[worksheet] ?? false,
            onChanged: worksheet.hasErrors()
                ? null
                : (isChecked) => setState(() {
                      _checkedCards[worksheet] = isChecked!;
                      widget.onStatusChanged(
                        widget.worksheets
                            .where((worksheet) =>
                                _checkedCards[worksheet]! &&
                                !worksheet.hasErrors())
                            .toList(),
                      );
                    }),
          ),
        ),
      )
      .toList();
}
