import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/bloc/editor/editor_view/worksheet_editor_bloc.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:kres_requests2/screens/editor/widgets/document_tabs_bar.dart';
import 'package:kres_requests2/screens/editor/worksheet_config_view/worksheet_config_view.dart';

import 'widgets/worksheet_editor_view.dart';
import 'widgets/worksheet_page_controller.dart';

extension on DocumentMasterState {
  int get pageCount =>
      this is ShowDocumentsState ? (this as ShowDocumentsState).all.length : 0;

  int get pageIndex {
    if (this is ShowDocumentsState) {
      final state = this as ShowDocumentsState;
      return state.all.indexWhere((info) => info.document == state.selected);
    } else {
      return 0;
    }
  }
}

/// Screen that manages whole document state
/// Requires [DocumentMasterBloc] to be injected as a [Modular] dependency
class DocumentEditorScreen extends HookWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  /// Defines whether create blank document on start or not
  final bool blankDocumentOnStart;

  DocumentEditorScreen({
    this.blankDocumentOnStart = false,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = Modular.get<DocumentMasterBloc>();

    useEffect(() {
      if (blankDocumentOnStart) {
        bloc.add(CreatePage());
      }
    });

    return BlocProvider<DocumentMasterBloc>.value(
      value: bloc,
      child: BlocBuilder<DocumentMasterBloc, DocumentMasterState>(
        builder: (context, state) {
          return DefaultTabController(
            length: state.pageCount,
            initialIndex: state.pageIndex,
            child: Scaffold(
              key: _scaffoldKey,
              endDrawer: _buildEndDrawer(),
              appBar: _buildAppBar(),
              body: BlocListener<DocumentMasterBloc, DocumentMasterState>(
                listener: (context, state) {
                  if (state is DocumentErrorState) {
                    _handleErrors(context, state);
                  }
                },
                child: Stack(children: [
                  Positioned.fill(child: _buildEditor(context, state)),
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
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80.0),
                      child: _buildEndDrawerButton(),
                    ),
                  )
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEndDrawer() =>
      BlocBuilder<DocumentMasterBloc, DocumentMasterState>(
        builder: (context, state) {
          if (state is! ShowDocumentsState) {
            return Container();
          }

          return Container(
            width: 420.0,
            child: Drawer(
              child: WorksheetConfigView(
                Modular.get<WorksheetServiceFactory>()
                    .createWorksheetService(state.selected),
              ),
            ),
          );
        },
      );

  Widget _buildEndDrawerButton() => Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
          ),
          color: Colors.white,
        ),
        child: IconButton(
          icon: Icon(Icons.menu_open),
          onPressed: () {
            _scaffoldKey.currentState!.openEndDrawer();
          },
        ),
      );

  AppBar _buildAppBar() => AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: Text('Редактор заявок'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: DocumentTabsBar(),
        ),
        actions: [
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.search),
            tooltip: 'Поиск',
            onPressed: (context) => context
                .read<DocumentMasterBloc>()
                .add(WorksheetMasterSearchEvent()),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.save),
            tooltip: 'Сохранить',
            onPressed: (context) =>
                context.read<DocumentMasterBloc>().add(SaveEvent()),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.solidSave),
            tooltip: 'Сохранить как (копия)',
            onPressed: (context) => context
                .read<DocumentMasterBloc>()
                .add(SaveEvent(changePath: true)),
          ),
          const SizedBox(width: 24.0),
          Builder(
            builder: (context) => IconButton(
              icon: FaIcon(FontAwesomeIcons.fileExport),
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

  void _handleErrors(BuildContext context, DocumentErrorState state) {
    final scaffold = ScaffoldMessenger.of(context);
    void showSnackbar(String message, Duration duration) =>
        scaffold.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
          ),
        );

    scaffold.removeCurrentSnackBar();

    if (state.error == DocumentErrorType.savingError) {
      print("${state.error}\n${state.stackTrace}");
      showSnackbar(
        'Не удалось сохранить! ${state.error}',
        const Duration(seconds: 6),
      );
    }
  }

  Widget _buildEditor(BuildContext context, DocumentMasterState state) {
    final List<DocumentInfo> allDocs;
    final Widget content;

    if (state is ShowDocumentsState) {
      allDocs = state.all;

      content = TabBarView(
        children: allDocs.map((docInfo) {
          final serviceFactory = Modular.get<WorksheetServiceFactory>();
          final document = docInfo.document;
          final worksheets = document.worksheets;
          final service = serviceFactory.createWorksheetService(document);

          return IndexedStack(
            index: worksheets.activePosition,
            children: worksheets.list
                .map((e) => BlocProvider(
                      key: ObjectKey(e),
                      create: (_) => WorksheetEditorBloc(service: service)
                        ..add(SetCurrentWorksheetEvent(e)),
                      child: WorksheetEditorView(),
                    ))
                .toList(),
          );
        }).toList(growable: false),
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
      onWillPop: () => _showExitConfirmationDialog(allDocs, context),
      child: Row(
        children: [
          Container(
            width: 285.0,
            height: double.maxFinite,
            child: WorksheetsPageController(),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFE5E5E5),
              height: double.maxFinite,
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(
      List<DocumentInfo> docs, BuildContext context) async {
    final isAllSaved =
        docs.isEmpty || docs.every((e) => e.saveState == SaveState.saved);

    if (!isAllSaved) return true;

    return true;
    // TODO: Stub
    // return await showDialog<bool>(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (ctx) => AlertDialog(
    //     title: Text('Сохранить документ перед выходом?'),
    //     actionsPadding: EdgeInsets.only(right: 24.0, bottom: 12.0),
    //     actions: [
    //       OutlinedButton(
    //         onPressed: () => Navigator.pop(ctx, false),
    //         child: Text('Отмена'),
    //       ),
    //       const SizedBox(width: 12.0),
    //       FlatButton(
    //         onPressed: () => Navigator.pop(ctx, true),
    //         child: Text('Нет'),
    //       ),
    //       const SizedBox(width: 12.0),
    //       RaisedButton(
    //         color: Theme.of(ctx).primaryColor,
    //         textColor: Theme.of(ctx).primaryTextTheme.bodyText2.color,
    //         onPressed: () => _worksheetBloc
    //             .add(WorksheetMasterSaveEvent(popAfterSave: true)),
    //         child: Text('Да'),
    //       ),
    //     ],
    //   ),
    // );
  }
}
