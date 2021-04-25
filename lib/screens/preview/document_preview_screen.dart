import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/bloc/exporter/exporter_bloc.dart';
import 'package:kres_requests2/bloc/preview/preview_bloc.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/preview/print_dialog.dart';

import 'exporter_dialogs.dart';
import 'widgets/worksheet_card_group.dart';

/// The page responsible for preparing document worksheets for printing or
/// exporting to external formats
class DocumentPreviewScreen extends StatelessWidget {
  /// Currently opened document
  final Document document;

  const DocumentPreviewScreen({
    required this.document,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вывод документа'),
      ),
      body: BlocProvider(
        create: (_) => PreviewBloc(document),
        child: BlocBuilder<PreviewBloc, PreviewState>(
          builder: (context, state) {
            if (state is EmptyDocumentState) {
              return Center(
                child: Text(
                  'Документ пуст',
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: Theme.of(context).textTheme.caption!.color),
                ),
              );
            } else if (state is ShowDocumentState) {
              return Builder(builder: (ctx) => _buildPage(ctx, state));
            } else {
              return LoadingView('...');
            }
          },
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    ShowDocumentState state,
  ) =>
      Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildActionsContainer(context, state),
          Expanded(
            child: WorksheetCardGroup(
              worksheets: state.allWorksheet,
              onStatusChanged: (newWorksheets) => context
                  .read<PreviewBloc>()
                  .add(UpdateSelectedEvent(newWorksheets)),
            ),
          ),
        ],
      );

  Widget _buildActionsContainer(
    BuildContext context,
    ShowDocumentState state,
  ) =>
      Container(
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
                  tooltip:
                      'Сохранить выбранные листы в формате Книга Microsoft '
                      'Excel 2007-365 (Только списки работ)',
                  onPressed: state.hasPrintableWorksheets
                      ? () =>
                          _showExportDialog(context, state, ExportFormat.Excel)
                      : null,
                ),
                _buildActionBarItem(
                  context: context,
                  icon: FontAwesomeIcons.filePdf,
                  label: 'Экспорт в PDF',
                  tooltip: 'Сохранить выбранные листы в формате PDF',
                  onPressed: state.hasPrintableWorksheets
                      ? () =>
                          _showExportDialog(context, state, ExportFormat.Pdf)
                      : null,
                ),
                _buildActionBarItem(
                  context: context,
                  icon: FontAwesomeIcons.print,
                  label: 'Печать',
                  tooltip: 'Отправить выбранные листы на печать',
                  onPressed: state.hasPrintableWorksheets
                      ? () => _showPrintDialog(context, state)
                      : null,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildActionBarItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String tooltip,
    VoidCallback? onPressed,
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
              color: Theme.of(context).primaryTextTheme.bodyText2!.color,
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
    ShowDocumentState documentState,
    ExportFormat format,
  ) =>
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ExporterDialog(format, documentState.printableDocument),
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

  Future _showPrintDialog(
    BuildContext context,
    ShowDocumentState documentState,
  ) =>
      showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PrintDialog(documentState.printableDocument),
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
