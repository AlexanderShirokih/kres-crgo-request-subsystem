import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/worksheets/worksheet_master_bloc.dart';
import 'package:kres_requests2/bloc/worksheets/worksheet_switcher_bloc.dart';
import 'package:kres_requests2/domain/document_service.dart';
import 'package:kres_requests2/models/request_set.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';
import 'package:kres_requests2/screens/editor/worksheet_tab_view.dart';

class WorksheetPageController extends StatelessWidget {
  final DocumentService _documentService;

  const WorksheetPageController(this._documentService);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: WorksheetSwitcherBloc(
        _documentService,
        context.watch<WorksheetMasterBloc>(),
      ),
      child: Builder(
        builder: (context) =>
            BlocBuilder<WorksheetSwitcherBloc, WorksheetSwitcherState>(
          cubit: context.watch<WorksheetSwitcherBloc>(),
          builder: (context, state) {
            if (state is WorksheetSwitcherShowWorksheets) {
              return _buildLayout(context, state.worksheets, state.active);
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _buildLayout(
    BuildContext context,
    List<RequestSet> worksheets,
    RequestSet active,
  ) {
    Widget withClosure(
            RequestSet current, Widget Function(RequestSet) closure) =>
        closure(current);

    return Container(
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
      child: ListView.builder(
        itemCount: worksheets.length + 1,
        itemBuilder: (context, index) => index == worksheets.length
            ? AddNewWorkSheetTabView((worksheetCreationMode) => context
                .read<WorksheetSwitcherBloc>()
                .add(WorksheetSwitcherAddNewEvent()))
            : withClosure(
                worksheets[index],
                (current) => WorkSheetTabView(
                  worksheet: current,
                  filteredItemsCount:
                      _documentService.filtered[current]?.length ?? 0,
                  isActive: current == active,
                  onSelect: () => context
                      .read<WorksheetSwitcherBloc>()
                      .add(WorksheetSwitcherSetActiveEvent(current)),
                  onRename: (newName) => context
                      .read<WorksheetSwitcherBloc>()
                      .add(WorksheetSwitcherRenameEvent(current, newName)),
                  onRemove: worksheets.length == 1
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
                                context
                                    .read<WorksheetSwitcherBloc>()
                                    .add(WorksheetSwitcherRemoveEvent(current));
                            });
                          } else
                            context
                                .read<WorksheetSwitcherBloc>()
                                .add(WorksheetSwitcherRemoveEvent(current));
                        },
                ),
              ),
      ),
    );
  }
}
