import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';

import 'worksheet_tab_view.dart';

/// Show a tabs for worksheets that currently exists in the document to
/// switch between pages
class WorksheetsPageController extends StatelessWidget {
  const WorksheetsPageController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentState = context.watch<DocumentMasterBloc>().state;

    if (currentState is! ShowDocumentsState) {
      return Container();
    }

    final document = currentState.selected;
    final worksheetsList = document.worksheets;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: StreamBuilder<List<Worksheet>>(
          stream: worksheetsList.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            final worksheets = snapshot.requireData;
            final active = worksheetsList.active;

            return ListView.builder(
                itemCount: worksheets.length + 1,
                itemBuilder: (context, index) {
                  return index == worksheets.length
                      ? AddNewWorkSheetTabView(
                          (worksheetCreationMode) =>
                              context.read<DocumentMasterBloc>().add(
                                    AddNewWorksheetEvent(worksheetCreationMode),
                                  ),
                        )
                      : _buildTabView(
                          context,
                          canRemove: worksheets.length == 1,
                          active: active,
                          editorBuilder: () =>
                              document.worksheets.edit(worksheets[index]),
                          current: worksheets[index],
                        );
                });
          }),
    );
  }

  Widget _buildTabView(
    BuildContext context, {
    required Worksheet current,
    required Worksheet active,
    required WorksheetEditor Function() editorBuilder,
    required bool canRemove,
  }) {
    return WorksheetTabView(
      key: ObjectKey(current),
      worksheet: current,
      editorBuilder: editorBuilder,
      filteredItemsCount:
          // TODO: Broken code
          // state is WorksheetMasterSearchingState
          //     ? state.filteredItems[current]?.length ?? 0:
          0,
      isActive: current == active,
      onSelect: () => context
          .read<DocumentMasterBloc>()
          .add(WorksheetActionEvent(current, WorksheetAction.makeActive)),
      onRemove: canRemove
          ? null
          : () {
              if (!current.isEmpty) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => ConfirmationDialog(
                    message: "Удалить страницу ${current.name}?",
                  ),
                ).then((result) {
                  if (result)
                    context.read<DocumentMasterBloc>().add(
                        WorksheetActionEvent(current, WorksheetAction.remove));
                });
              } else {
                context
                    .read<DocumentMasterBloc>()
                    .add(WorksheetActionEvent(current, WorksheetAction.remove));
              }
            },
    );
  }
}
