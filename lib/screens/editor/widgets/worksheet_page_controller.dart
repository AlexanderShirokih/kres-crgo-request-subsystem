import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/worksheets/worksheet_master_bloc.dart';
import 'package:kres_requests2/domain/controller/worksheet_editor.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';

import 'worksheet_tab_view.dart';

/// Show a tabs for worksheets that currently exists in the document
class WorksheetsPageController extends StatelessWidget {
  /// Currently opened document
  final Document document;

  const WorksheetsPageController({Key? key, required this.document})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: StreamBuilder<List<Worksheet>>(
          stream: document.worksheets,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            final worksheets = snapshot.requireData;
            final active = document.currentActive;

            return ListView.builder(
                itemCount: worksheets.length + 1,
                itemBuilder: (context, index) {
                  return index == worksheets.length
                      ? AddNewWorkSheetTabView(
                          (worksheetCreationMode) =>
                              context.read<WorksheetMasterBloc>().add(
                                    WorksheetMasterAddNewWorksheetEvent(
                                        worksheetCreationMode),
                                  ),
                        )
                      : _buildTabView(
                          context,
                          canRemove: worksheets.length == 1,
                          active: active,
                          currentEditor: document.edit(worksheets[index]),
                        );
                });
          }),
    );
  }

  Widget _buildTabView(
    BuildContext context, {
    required WorksheetEditor currentEditor,
    required Worksheet active,
    required bool canRemove,
  }) {
    final current = currentEditor.current;
    return WorksheetTabView(
      key: ObjectKey(currentEditor.current),
      worksheetEditor: currentEditor,
      filteredItemsCount:
          // TODO: Broken code
          // state is WorksheetMasterSearchingState
          //     ? state.filteredItems[current]?.length ?? 0:
          0,
      isActive: current == active,
      onSelect: () => context.read<WorksheetMasterBloc>().add(
          WorksheetMasterWorksheetActionEvent(
              current, WorksheetAction.makeActive)),
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
                    context.read<WorksheetMasterBloc>().add(
                        WorksheetMasterWorksheetActionEvent(
                            current, WorksheetAction.remove));
                });
              } else {
                context.read<WorksheetMasterBloc>().add(
                    WorksheetMasterWorksheetActionEvent(
                        current, WorksheetAction.remove));
              }
            },
    );
  }
}
