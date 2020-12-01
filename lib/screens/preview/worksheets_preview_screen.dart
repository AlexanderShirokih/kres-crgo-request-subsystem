import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kres_requests2/bloc/exporter/exporter_bloc.dart';
import 'package:kres_requests2/bloc/preview/preview_bloc.dart';
import 'package:kres_requests2/domain/document_service.dart';
import 'package:kres_requests2/domain/request_set_service.dart';
import 'package:kres_requests2/models/employee.dart';
import 'package:kres_requests2/models/request_set.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/common.dart';

import 'exporter_dialogs.dart';
import 'print_dialog.dart';

class WorksheetsPreviewScreen extends StatelessWidget {
  final RepositoryModule repositoryModule;
  final PreviewBloc _previewBloc;

  WorksheetsPreviewScreen(DocumentService document, this.repositoryModule)
      : _previewBloc = PreviewBloc(
          document,
          repositoryModule.getExportRepository(),
        ),
        assert(document != null),
        assert(repositoryModule != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вывод документа'),
      ),
      body: BlocBuilder<PreviewBloc, PreviewState>(
        cubit: _previewBloc,
        builder: (context, state) {
          if (state is PreviewEmptyDocumentState) {
            return Center(
              child: Text(
                'Документ пуст',
                style: Theme.of(context)
                    .textTheme
                    .headline4
                    .copyWith(color: Theme.of(context).textTheme.caption.color),
              ),
            );
          } else if (state is PreviewDataState) {
            return BlocProvider.value(
              value: _previewBloc,
              child: Builder(
                  builder: (ctx) => _buildPage(ctx, state.validatedWorksheets)),
            );
          } else if (state is PreviewValidationState) {
            return Center(
              child: Text(
                'Проверка документа...',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(fontSize: 36.0),
              ),
            );
          } else {
            return LoadingView();
          }
        },
      ),
    );
  }

  Widget _buildPage(BuildContext context,
          Map<RequestSetService, WorksheetInfo> worksheets) =>
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildActionsContainer(
            context,
            worksheets,
          ),
          Expanded(child: _WorksheetCardGroup(worksheets)),
        ],
      );

  Widget _buildActionsContainer(
    BuildContext context,
    Map<RequestSetService, WorksheetInfo> data,
  ) {
    final checkedItems = data.entries.where((e) => e.value.isChecked);
    final hasPrintableWorksheets = checkedItems.isNotEmpty;
    final selected = checkedItems.map((e) => e.key.getRequestSet()).toList();

    return Container(
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
                icon: FontAwesomeIcons.fileExcel,
                label: 'Экспорт в Excel',
                tooltip: 'Сохранить выбранные листы в формате Книга Microsoft '
                    'Excel 2007-365 (Только списки работ)',
                onPressed: hasPrintableWorksheets
                    ? () => _showExportDialog(
                          context,
                          selected,
                          ExportFormat.Excel,
                        )
                    : null,
              ),
              _buildActionBarItem(
                context: context,
                icon: FontAwesomeIcons.filePdf,
                label: 'Экспорт в PDF',
                tooltip: 'Сохранить выбранные листы в формате PDF',
                onPressed: hasPrintableWorksheets
                    ? () => _showExportDialog(
                          context,
                          selected,
                          ExportFormat.Pdf,
                        )
                    : null,
              ),
              _buildActionBarItem(
                context: context,
                icon: FontAwesomeIcons.print,
                label: 'Печать',
                tooltip: 'Отправить выбранные листы на печать',
                onPressed: hasPrintableWorksheets
                    ? () => _showPrintDialog(context, selected)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Future _showExportDialog(
    BuildContext context,
    List<RequestSet> selected,
    ExportFormat format,
  ) =>
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ExporterDialog(
          format,
          selected,
          (ext) => getSuggestedName(ext),
        ),
      ).then(
        (resultMessage) {
          if (resultMessage != null)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resultMessage),
                duration: Duration(seconds: 6),
              ),
            );
        },
      );

  String getSuggestedName(String ext) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    String fmtDate(DateTime d) => dateFormat.format(d);
    return "Заявки ${fmtDate(DateTime.now())}$ext";
  }

  Future _showPrintDialog(
    BuildContext context,
    List<RequestSet> selected,
  ) =>
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PrintDialog(selected),
      ).then(
        (resultMessage) {
          if (resultMessage != null)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resultMessage),
                duration: Duration(seconds: 6),
              ),
            );
        },
      );
}

class _WorksheetCardGroup extends StatelessWidget {
  static const _tileMaxWidth = 500.0;

  final Map<RequestSetService, WorksheetInfo> worksheets;

  const _WorksheetCardGroup(this.worksheets) : assert(worksheets != null);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(-0.8, -0.8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = max(1, constraints.maxWidth ~/ _tileMaxWidth);
          return crossAxisCount > 1 && worksheets.length > 1
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

  List<Widget> _buildChildren(BuildContext context) => worksheets.entries.map(
        (MapEntry<RequestSetService, WorksheetInfo> worksheet) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _tileMaxWidth,
            ),
            child: WorksheetCard(
              worksheet: worksheet.key,
              errors: worksheet.value.errors,
              isSelected: worksheet.value.isChecked,
              onChanged: (isChecked) {
                if (worksheet.value.errors.isEmpty) {
                  context.read<PreviewBloc>().add(
                        PreviewSelectionChangedEvent(worksheet.key, isChecked),
                      );
                }
              },
            ),
          );
        },
      ).toList();
}

class WorksheetCard extends StatelessWidget {
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  final ValueChanged<bool> onChanged;
  final RequestSetService worksheet;
  final List<String> errors;
  final bool isSelected;

  const WorksheetCard({
    @required this.worksheet,
    @required this.isSelected,
    @required this.onChanged,
    @required this.errors,
  })  : assert(worksheet != null),
        assert(isSelected != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        child: InkWell(
          onTap: () => onChanged(!isSelected),
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
                        worksheet.getName(),
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
                  _showSubtitle(context, 'Заявок:',
                      Text('${worksheet.getRequests().length}')),
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
              worksheet.getChiefEmployee(),
            ),
            const SizedBox(height: 8.0),
            _printSingleEmployeeField(
              ctx,
              'Производитель работ:',
              worksheet.getMainEmployee(),
            ),
            const SizedBox(height: 8.0),
            _printMultipleChildField(
              ctx,
              'Члены бригады:',
              worksheet.getMembersEmployee(),
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
        textBaseline: TextBaseline.alphabetic,
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
        worksheet.getDate() == null
            ? Text('Не выбрано', style: _createErrorTextStyle(context))
            : Text('${_dateFormat.format(worksheet.getDate())}'),
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

  Widget _joinWorkTypes(BuildContext ctx) => worksheet.getRequestTypes().isEmpty
      ? Text(
          'Не выбран ни один вид работ',
          style: _createErrorTextStyle(ctx),
          textAlign: TextAlign.center,
        )
      : Flexible(
          child: Text(
            worksheet.getRequestTypes().map((e) => e.fullName).join(', '),
          ),
        );

  TextStyle _createErrorTextStyle(BuildContext ctx) =>
      Theme.of(ctx).textTheme.subtitle1.copyWith(
            color: Theme.of(ctx).errorColor,
            fontWeight: FontWeight.w800,
            fontSize: 18.0,
          );

  Widget _printWorksheetStatus(BuildContext context) {
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
