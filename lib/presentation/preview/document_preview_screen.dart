import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/presentation/bloc/preview/preview_bloc.dart';
import 'package:kres_requests2/presentation/common.dart';
import 'package:kres_requests2/presentation/preview/print_dialog.dart';

import 'exporter_dialog.dart';
import 'widgets/worksheet_card_group.dart';

/// The page responsible for preparing document worksheets for printing or
/// exporting to external formats
/// Requires [PreviewBloc] to be injected in the widget tree.
class DocumentPreviewScreen extends StatelessWidget {
  const DocumentPreviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<PreviewBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Вывод документа'),
        ),
        body: BlocBuilder<PreviewBloc, PreviewState>(
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
              return const LoadingView('...');
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
                          _showExportDialog(context, state, ExportFormat.excel)
                      : null,
                ),
                _buildActionBarItem(
                  context: context,
                  icon: FontAwesomeIcons.filePdf,
                  label: 'Экспорт в PDF',
                  tooltip: 'Сохранить выбранные листы в формате PDF',
                  onPressed: state.hasPrintableWorksheets
                      ? () =>
                          _showExportDialog(context, state, ExportFormat.pdf)
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
          if (resultMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resultMessage),
                duration: const Duration(seconds: 6),
              ),
            );
          }
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
          if (resultMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resultMessage),
                duration: const Duration(seconds: 6),
              ),
            );
          }
        },
      );
}
