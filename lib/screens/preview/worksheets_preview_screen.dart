import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/document.dart';
import 'package:kres_requests2/data/worksheet.dart';
import 'package:kres_requests2/screens/common.dart';

class WorksheetsPreviewScreen extends StatefulWidget {
  final Document document;

  const WorksheetsPreviewScreen(this.document);

  @override
  _WorksheetsPreviewScreenState createState() =>
      _WorksheetsPreviewScreenState(document);
}

class _WorksheetsPreviewScreenState extends State<WorksheetsPreviewScreen>
    with DocumentSaverMixin {
  @override
  Document currentDocument;

  _WorksheetsPreviewScreenState(this.currentDocument);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вывод документа'),
      ),
      body: widget.document.isEmpty
          ? Center(
              child: Text(
                'Документ пуст',
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Theme.of(context).textTheme.caption.color),
              ),
            )
          : Builder(builder: (ctx) => _buildPage(ctx)),
    );
  }

  Widget _buildPage(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildActionsContainer(context),
          Expanded(
            child: _WorksheetCardGroup(currentDocument.worksheets),
          ),
        ],
      );

  Widget _buildActionsContainer(BuildContext context) => Container(
        width: 340.0,
        height: double.maxFinite,
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildActionBarItem(
                  context: context,
                  icon: FontAwesomeIcons.save,
                  label: 'Сохранить',
                  onPressed: () => saveDocument(context, false),
                ),
                _buildActionBarItem(
                  context: context,
                  icon: FontAwesomeIcons.filePdf,
                  label: 'Экспорт в PDF',
                  onPressed: () {
                    // TODO : Export PDF
                  },
                ),
                _buildActionBarItem(
                  context: context,
                  icon: FontAwesomeIcons.print,
                  label: 'Печать',
                  onPressed: () {
                    // TODO: Print
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildActionBarItem({
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  }) =>
      Material(
        color: Theme.of(context).primaryColor,
        borderOnForeground: false,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          leading: FaIcon(
            icon,
            color: Theme.of(context).primaryTextTheme.bodyText2.color,
          ),
          title: Text(
            label,
            style: Theme.of(context).primaryTextTheme.subtitle1,
          ),
          onTap: onPressed,
        ),
      );
}

class _WorksheetCardGroup extends StatefulWidget {
  final List<Worksheet> worksheets;

  const _WorksheetCardGroup(this.worksheets);

  @override
  _WorksheetCardGroupState createState() => _WorksheetCardGroupState();
}

class _WorksheetCardGroupState extends State<_WorksheetCardGroup> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-0.8, -0.8),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: widget.worksheets
              .map(
                (worksheet) => WorksheetCard(
                  worksheet: worksheet,
                  isSelected: true,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class WorksheetCard extends StatelessWidget {
  final Worksheet worksheet;
  final bool isSelected;

  const WorksheetCard({
    this.worksheet,
    this.isSelected,
  })  : assert(worksheet != null),
        assert(isSelected != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        child: InkWell(
          onTap: () {},
          child: Card(
            elevation: 5.0,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              width: 400.0,
              height: 180.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    worksheet.name,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
