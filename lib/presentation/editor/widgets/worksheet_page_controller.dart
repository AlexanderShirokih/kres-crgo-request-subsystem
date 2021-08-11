import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/doc_view/document_bloc.dart';
import 'package:kres_requests2/presentation/confirmation_dialog.dart';

import 'worksheet_tab_view.dart';

/// Show a tabs for worksheets that currently exists in the document to
/// switch between pages
/// Requires [DocumentBloc] to be injected in the widget tree
class WorksheetsPageController extends StatelessWidget {
  const WorksheetsPageController({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentState = context.watch<DocumentBloc>().state;

    if (currentState is! DataState<DocumentInfo>) {
      return Container();
    }

    final documentInfo = currentState.data;
    final worksheets = documentInfo.all;
    final active = documentInfo.active;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ListView.builder(
          itemCount: worksheets.length + 1,
          itemBuilder: (context, index) {
            return index == worksheets.length
                ? AddNewWorkSheetTabView(
                    () => context
                        .read<DocumentBloc>()
                        .add(const AddNewWorksheetEvent()),
                  )
                : _buildTabView(
                    context,
                    canRemove: worksheets.length == 1,
                    isActive: worksheets[index] == active,
                    current: worksheets[index],
                  );
          }),
    );
  }

  Widget _buildTabView(
    BuildContext context, {
    required Worksheet current,
    required bool isActive,
    required bool canRemove,
  }) {
    return WorksheetTabView(
      key: ObjectKey(current),
      worksheet: current,
      filteredItemsCount:
          // TODO: Broken code
          // state is WorksheetMasterSearchingState
          //     ? state.filteredItems[current]?.length ?? 0:
          0,
      isActive: isActive,
      onSelect: () => context
          .read<DocumentBloc>()
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
                  if (result) {
                    context.read<DocumentBloc>().add(
                        WorksheetActionEvent(current, WorksheetAction.remove));
                  }
                });
              } else {
                context
                    .read<DocumentBloc>()
                    .add(WorksheetActionEvent(current, WorksheetAction.remove));
              }
            },
    );
  }
}
