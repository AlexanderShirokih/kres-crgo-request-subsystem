import 'dart:math';

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/document.dart';
import 'package:kres_requests2/data/employee.dart';
import 'package:kres_requests2/data/worksheet.dart';
import 'package:kres_requests2/screens/common.dart';

import 'exporter_dialogs.dart';

class WorksheetsPreviewScreen extends StatefulWidget {
  final Document document;

  const WorksheetsPreviewScreen(this.document) : assert(document != null);

  @override
  _WorksheetsPreviewScreenState createState() =>
      _WorksheetsPreviewScreenState(document);
}

class _WorksheetsPreviewScreenState extends State<WorksheetsPreviewScreen>
    with DocumentSaverMixin {
  @override
  Document currentDocument;

  List<Worksheet> selectedWorksheets;

  @override
  void initState() {
    super.initState();
    selectedWorksheets = currentDocument.worksheets
        .where((worksheet) => !worksheet.isEmpty && !worksheet.hasErrors())
        .toList();
  }

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
            child: _WorksheetCardGroup(
              worksheets: currentDocument.worksheets
                  .where((worksheet) => !worksheet.isEmpty)
                  .toList(),
              onStatusChanged: (newWorksheets) => setState(() {
                selectedWorksheets = newWorksheets;
              }),
            ),
          ),
        ],
      );

  bool hasPrintableWorksheets() => selectedWorksheets.isNotEmpty;

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
                  tooltip: 'Сохранить файл',
                  onPressed: () => saveDocument(context, false),
                ),
                _buildActionBarItem(
                  context: context,
                  icon: FontAwesomeIcons.filePdf,
                  label: 'Экспорт в PDF',
                  tooltip: 'Сохранить выбранные листы в формате PDF',
                  onPressed: hasPrintableWorksheets()
                      ? () => _showExportDialog(context)
                      : null,
                ),
                _buildActionBarItem(
                  context: context,
                  icon: FontAwesomeIcons.print,
                  label: 'Печать',
                  tooltip: 'Отправить выбранные листы на печать',
                  onPressed: hasPrintableWorksheets()
                      ? () {
                          // TODO: Print
                        }
                      : null,
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
    String tooltip,
    VoidCallback onPressed,
  }) =>
      Material(
        color: Theme.of(context).primaryColor,
        borderOnForeground: false,
        child: Tooltip(
          message: tooltip,
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
        ),
      );

  Future _showExportDialog(BuildContext context) => showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ExportToPDFDialog(
          selectedWorksheets,
          getSuggestedName(".pdf"),
        ),
      ).then(
        (resultMessage) {
          if (resultMessage != null)
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(resultMessage),
                duration: Duration(seconds: 6),
              ),
            );
        },
      );
}

class _WorksheetCardGroup extends StatefulWidget {
  final List<Worksheet> worksheets;

  final void Function(List<Worksheet>) onStatusChanged;

  const _WorksheetCardGroup({
    @required this.worksheets,
    @required this.onStatusChanged,
  })  : assert(worksheets != null),
        assert(onStatusChanged != null);

  @override
  _WorksheetCardGroupState createState() => _WorksheetCardGroupState();
}

class _WorksheetCardGroupState extends State<_WorksheetCardGroup> {
  static const _tileMaxWidth = 500.0;

  Map<Worksheet, bool> _checkedCards;

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
            isSelected: _checkedCards[worksheet],
            onChanged: worksheet.hasErrors()
                ? null
                : (isChecked) => setState(() {
                      _checkedCards[worksheet] = isChecked;
                      widget.onStatusChanged(
                        widget.worksheets
                            .where((worksheet) =>
                                _checkedCards[worksheet] &&
                                !worksheet.hasErrors())
                            .toList(),
                      );
                    }),
          ),
        ),
      )
      .toList();
}

class WorksheetCard extends StatelessWidget {
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  final ValueChanged<bool> onChanged;
  final Worksheet worksheet;
  final bool isSelected;

  const WorksheetCard({
    @required this.worksheet,
    @required this.isSelected,
    @required this.onChanged,
  })  : assert(worksheet != null),
        assert(isSelected != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        child: InkWell(
          onTap: () => onChanged?.call(!isSelected),
          child: Card(
            elevation: 5.0,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        worksheet.name,
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Checkbox(
                            value: isSelected,
                            onChanged: onChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _showEmployees(context),
                  const SizedBox(height: 8.0),
                  _showSubtitle(
                      context, 'Виды работ:', _joinWorkTypes(context)),
                  const SizedBox(height: 8.0),
                  _showDate(context),
                  const SizedBox(height: 8.0),
                  _showSubtitle(
                      context, 'Заявок:', Text('${worksheet.requests.length}')),
                  const SizedBox(height: 8.0),
                  _printWorksheetStatus(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showEmployees(BuildContext ctx) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _printSingleEmployeeField(
              ctx,
              'Выдающий задание:',
              worksheet.chiefEmployee,
            ),
            const SizedBox(height: 8.0),
            _printSingleEmployeeField(
              ctx,
              'Производитель работ:',
              worksheet.mainEmployee,
            ),
            const SizedBox(height: 8.0),
            _printMultipleChildField(
              ctx,
              'Члены бригады:',
              worksheet.membersEmployee,
            ),
          ],
        ),
      );

  Widget _printSingleEmployeeField(
          BuildContext ctx, String label, Employee emp) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: [
          _printEmployeeLabel(ctx, label),
          const SizedBox(width: 6.0),
          _printEmployee(ctx, emp),
        ],
      );

  Widget _printMultipleChildField(
          BuildContext ctx, String label, List<Employee> emp) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _printEmployeeLabel(ctx, label),
          const SizedBox(width: 6.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: emp.map((e) => _printEmployee(ctx, e)).toList(),
          )
        ],
      );

  Widget _printEmployeeLabel(BuildContext ctx, String label) => Container(
        width: 180.0,
        child: Text(
          label,
          style: Theme.of(ctx).textTheme.subtitle1.copyWith(fontSize: 18.0),
        ),
      );

  Widget _printEmployee(BuildContext ctx, Employee emp) {
    return emp == null
        ? Text(
            'Не выбрано',
            style: _createErrorTextStyle(ctx),
          )
        : Text(
            emp.name,
            style: Theme.of(ctx).textTheme.subtitle1.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.0,
                ),
            textAlign: TextAlign.start,
          );
  }

  Widget _showDate(BuildContext context) => _showSubtitle(
        context,
        'Дата выдачи:',
        worksheet.date == null
            ? Text('Не выбрано', style: _createErrorTextStyle(context))
            : Text('${_dateFormat.format(worksheet.date)}'),
      );

  Widget _showSubtitle(BuildContext context, String label, Widget child) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          const SizedBox(
            width: 12.0,
          ),
          child,
        ],
      );

  Widget _joinWorkTypes(BuildContext ctx) => worksheet.workTypes.isEmpty
      ? Text(
          'Не выбран ни один вид работ',
          style: _createErrorTextStyle(ctx),
          textAlign: TextAlign.center,
        )
      : Flexible(
          child: Text(
            worksheet.workTypes.join(', '),
          ),
        );

  TextStyle _createErrorTextStyle(BuildContext ctx) =>
      Theme.of(ctx).textTheme.subtitle1.copyWith(
            color: Theme.of(ctx).errorColor,
            fontWeight: FontWeight.w800,
            fontSize: 18.0,
          );

  Widget _printWorksheetStatus(BuildContext context) {
    final errors = worksheet.validate().toList();

    if (errors.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(FontAwesomeIcons.check, color: Colors.green),
          const SizedBox(width: 12.0),
          Text('Готово к печати'),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Обнаружены следующие ошибки: ',
            style: _createErrorTextStyle(context),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: errors
                  .map(
                    (e) => ListTile(
                      leading: FaIcon(FontAwesomeIcons.exclamationCircle),
                      title: Text(e),
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      );
    }
  }
}
