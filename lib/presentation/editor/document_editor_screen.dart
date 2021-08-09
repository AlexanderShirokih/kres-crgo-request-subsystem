import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:kres_requests2/presentation/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/presentation/common/dialog_service.dart';
import 'package:kres_requests2/presentation/editor/save_before_exit_dialog.dart';
import 'package:kres_requests2/presentation/editor/widgets/document_tabs_bar.dart';
import 'package:window_control/window_listener.dart';

import 'document_module.dart';

/// Screen that manages whole document state
/// Requires [DocumentMasterBloc] to be injected as a [Modular] dependency
class DocumentEditorScreen extends HookWidget {
  /// Defines whether create blank document on start or not
  final bool blankDocumentOnStart;

  const DocumentEditorScreen({
    Key? key,
    this.blankDocumentOnStart = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Modular.get<DocumentMasterBloc>();

    useEffect(() {
      if (blankDocumentOnStart) {
        bloc.add(const CreatePage(false));
      }
    });

    return BlocProvider<DocumentMasterBloc>.value(
      value: bloc,
      child: BlocBuilder<DocumentMasterBloc, DocumentMasterState>(
        builder: (context, state) {
          return WindowStateListener(
            onWindowClosing: () async =>
                await _showExitConfirmationDialog(context),
            child: DefaultTabController(
              length: state.pageCount,
              initialIndex: state.pageIndex,
              child: Scaffold(
                appBar: _buildAppBar(),
                body: DialogManager(
                  dialogService: Modular.get(),
                  child: Stack(children: [
                    Positioned.fill(
                      child: _buildEditor(context, state),
                    ),
                    // FIXME: BROKEN
                    // if (state is WorksheetMasterSearchingState)
                    // Align(
                    //   alignment: Alignment.topRight,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(top: 12.0, right: 12.0),
                    //     child: SearchBox(
                    //       textWatcher: (String searchText) => context
                    //           .read<WorksheetMasterBloc>()
                    //           .add(WorksheetMasterSearchEvent(searchText)),
                    //     ),
                    //   ),
                    // ),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
        title: const Text('Редактор заявок'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: DocumentTabsBar(),
        ),
        actions: [
          _createActionButton(
            icon: const FaIcon(FontAwesomeIcons.search),
            tooltip: 'Поиск',
            onPressed: (context) => context
                .read<DocumentMasterBloc>()
                .add(const WorksheetMasterSearchEvent()),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: const FaIcon(FontAwesomeIcons.save),
            tooltip: 'Сохранить',
            onPressed: (context) =>
                context.read<DocumentMasterBloc>().add(const SaveEvent()),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: const FaIcon(FontAwesomeIcons.solidSave),
            tooltip: 'Сохранить как (копия)',
            onPressed: (context) => context
                .read<DocumentMasterBloc>()
                .add(const SaveEvent(changePath: true)),
          ),
          const SizedBox(width: 24.0),
          Builder(
            builder: (context) => IconButton(
              icon: const FaIcon(FontAwesomeIcons.fileExport),
              tooltip: 'Вывод',
              onPressed: () => Modular.to.pushNamed('preview'),
            ),
          ),
          const SizedBox(width: 24.0),
        ],
      );

  Widget _createActionButton({
    required Widget icon,
    required String tooltip,
    required void Function(BuildContext) onPressed,
  }) =>
      Builder(
        builder: (ctx) => IconButton(
          icon: icon,
          tooltip: tooltip,
          onPressed: () => onPressed(ctx),
        ),
      );

  Widget _buildEditor(
    BuildContext context,
    DocumentMasterState state,
  ) {
    final List<DocumentInfo> allDocs;
    final Widget content;

    if (state is ShowDocumentsState) {
      allDocs = state.all;

      content = TabBarView(
        children: allDocs
            .map((docInfo) => DocumentScope(docInfo.document))
            .toList(growable: false),
      );
    } else {
      allDocs = [];
      content = Center(
        child: Text(
          'Создайте документ для начала работы',
          style: Theme.of(context).textTheme.headline3,
        ),
      );
    }

    return WillPopScope(
      onWillPop: () => _showExitConfirmationDialog(context),
      child: content,
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final documentManager = Modular.get<DocumentManager>();

    if (documentManager.unsaved.isEmpty) return true;

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.watch<DocumentMasterBloc>(),
        child: SaveBeforeExitDialog(
          documentManager: documentManager,
        ),
      ),
    );

    return false;
  }
}
