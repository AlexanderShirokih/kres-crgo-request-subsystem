import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TableHeadingColumn {
  final Widget label;
  final double preferredWidth;

  const TableHeadingColumn({
    required this.label,
    this.preferredWidth = 200.0,
  });
}

class TableDataRow {
  final Key? key;
  final List<Widget> cells;

  const TableDataRow({
    this.key,
    required this.cells,
  });
}

class TableView extends StatelessWidget {
  final ScrollController? controller;
  final List<TableHeadingColumn> header;
  final List<TableDataRow> rows;

  final TextStyle? headingTextStyle;
  final TextStyle? rowsTextStyle;
  final Widget? headerTrailing;

  const TableView({
    Key? key,
    this.headingTextStyle,
    this.headerTrailing,
    this.rowsTextStyle,
    this.controller,
    required this.header,
    required this.rows,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeading(context),
        _buildRows(context),
      ],
    );
  }

  Widget _buildRows(BuildContext context) {
    final separatorColor = Colors.grey[300]!;
    return Expanded(
      child: DefaultTextStyle(
        style: rowsTextStyle ?? Theme.of(context).textTheme.bodyText2!,
        child: ListView.builder(
          controller: controller,
          itemCount: rows.length,
          itemBuilder: (context, row) => Container(
            decoration: BoxDecoration(
              border: Border.all(color: separatorColor, width: 0.5),
            ),
            child: Row(
              key: rows[row].key,
              children: List.generate(
                header.length,
                (index) => SizedBox(
                  width: header[index].preferredWidth,
                  child: rows[row].cells[index],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(BuildContext context) => Material(
        elevation: 4.0,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: DefaultTextStyle(
            style: headingTextStyle ?? Theme.of(context).textTheme.headline6!,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: header
                      .map(
                        (e) => SizedBox(
                          width: e.preferredWidth,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: e.label,
                          ),
                        ),
                      )
                      .toList()
                      .cast<Widget>() +
                  [
                    Expanded(
                      child: headerTrailing ?? const SizedBox(),
                    ),
                  ],
            ),
          ),
        ),
      );
}
