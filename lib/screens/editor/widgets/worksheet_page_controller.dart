import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/worksheets/worksheet_master_bloc.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';

import 'worksheet_tab_view.dart';

/// Show a tabs for worksheets currently exists in the document
class WorksheetsPageController extends StatelessWidget {
  /// List of the document worksheets
  final Stream<List<Worksheet>> worksheets;

  /// Currently active worksheet
  final Stream<Worksheet> activeWorksheet;

  const WorksheetsPageController({
    Key? key,
    required this.worksheets,
    required this.activeWorksheet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        width: 280.0,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: 2.0,
              color: Theme.of(context).secondaryHeaderColor,
              style: BorderStyle.solid,
            ),
          ),
        ),
        height: double.maxFinite,
        child: StreamBuilder<List<Worksheet>>(
          stream: worksheets,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            final worksheets = snapshot.requireData;
            return StreamBuilder<Worksheet>(
              stream: activeWorksheet,
              builder: (context, snap) {
                return snap.hasData
                    ? ListView.builder(
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
                                  current: worksheets[index],
                                  canRemove: worksheets.length == 1,
                                  active: snap.requireData,
                                );
                        })
                    : Container();
              },
            );
          },
        ),
      );

  Widget _buildTabView(
    BuildContext context, {
    required Worksheet current,
    required Worksheet active,
    required bool canRemove,
  }) {
    return WorksheetTabView(
      worksheet: current,
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
              } else
                context.read<WorksheetMasterBloc>().add(
                    WorksheetMasterWorksheetActionEvent(
                        current, WorksheetAction.remove));
            },
    );
  }
}
