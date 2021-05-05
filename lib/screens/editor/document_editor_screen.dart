import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/bloc/editor/editor_view/worksheet_editor_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/screens/editor/worksheet_config_view/worksheet_config_view.dart';

import 'widgets/worksheet_editor_view.dart';
import 'widgets/worksheet_page_controller.dart';

/// Screen that manages whole document state
/// Requires [DocumentMasterBloc] to be injected in the widget ancestor.
class DocumentEditorScreen extends HookWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final document = context.watch<DocumentMasterBloc>().state.currentDocument;
    // final worksheetsSnap =
    //     useStream(document.worksheets, initialData: <Worksheet>[]);
    //
    final worksheets = document.currentWorksheets; //worksheetsSnap.requireData;

    if (worksheets.isEmpty) {
      return Material(
        child: Column(
          children: [
            Text('Документ пуст!'),
            BackButton(),
          ],
        ),
      );
    }

    final active = useState(worksheets.first);

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildEndDrawer(active),
      appBar: _buildAppBar(),
      body: BlocConsumer<DocumentMasterBloc, DocumentMasterState>(
        listener: (context, state) {
          if (state is WorksheetMasterSavingState) {
            _handleSavingState(context, state);
          }
        },
        builder: (context, state) {
          // FIXME: BROKEN
          // if (state is WorksheetMasterSearchingState) {
          //   return Stack(children: [
          //     Positioned.fill(child: _buildBody(context, state)),
          //     Align(
          //       alignment: Alignment.topRight,
          //       child: Padding(
          //         padding: const EdgeInsets.only(top: 12.0, right: 12.0),
          //         child: SearchBox(
          //           textWatcher: (String searchText) => context
          //               .read<WorksheetMasterBloc>()
          //               .add(WorksheetMasterSearchEvent(searchText)),
          //         ),
          //       ),
          //     ),
          //   ]);
          // } else {
          return Stack(children: [
            Positioned.fill(
              child: _buildEditor(
                context,
                state,
                active,
                worksheets,
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Container(
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
                ),
              ),
            )
          ]);
          // }
        },
      ),
    );
  }

  Widget _buildEndDrawer(ValueNotifier<Worksheet> active) =>
      BlocBuilder<DocumentMasterBloc, DocumentMasterState>(
        builder: (context, state) => Container(
          width: 420.0,
          child: Drawer(
            child: WorksheetConfigView(
              Modular.get(),
              state.currentDocument.edit(active.value),
            ),
          ),
        ),
      );

  AppBar _buildAppBar() => AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: Builder(
          builder: (context) => StreamBuilder<String>(
            stream: context.watch<DocumentMasterBloc>().state.documentTitle,
            builder: (_, snap) => Text(
                'Редактирование - ${snap.data ?? "Несохранённый документ"}'),
          ),
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
            onPressed: (context) => context
                .read<DocumentMasterBloc>()
                .add(WorksheetMasterSaveEvent()),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.solidSave),
            tooltip: 'Сохранить как (копия)',
            onPressed: (context) => context
                .read<DocumentMasterBloc>()
                .add(WorksheetMasterSaveEvent(changePath: true)),
          ),
          const SizedBox(width: 24.0),
          Builder(
            builder: (context) => IconButton(
              icon: FaIcon(FontAwesomeIcons.fileExport),
              tooltip: 'Вывод',
              onPressed: () => Modular.to.pushNamed(
                'preview',
                arguments:
                    context.read<DocumentMasterBloc>().state.currentDocument,
              ),
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

  void _handleSavingState(
      BuildContext context, WorksheetMasterSavingState state) {
    final scaffold = ScaffoldMessenger.of(context);
    void showSnackbar(String message, Duration duration) =>
        scaffold.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
          ),
        );

    scaffold.removeCurrentSnackBar();

    if (state.error != null) {
      print("${state.error}\n${state.stackTrace}");
      showSnackbar(
        'Не удалось сохранить! ${state.error}',
        const Duration(seconds: 6),
      );
    } else if (state.completed) {
      showSnackbar(
        'Документ сохранён',
        const Duration(seconds: 2),
      );
    } else {
      showSnackbar('Сохранение...', const Duration(seconds: 5));
    }
  }

  Widget _buildEditor(
    BuildContext context,
    DocumentMasterState state,
    ValueNotifier<Worksheet> active,
    List<Worksheet> worksheets,
  ) {
    return WillPopScope(
      onWillPop: () =>
          _showExitConfirmationDialog(state.currentDocument, context),
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
              child: IndexedStack(
                index: worksheets.indexOf(active.value),
                children: worksheets
                    .map((e) => BlocProvider(
                          key: ObjectKey(e),
                          create: (_) => WorksheetEditorBloc(
                            worksheet: state.currentDocument.edit(e),
                          ),
                          child: WorksheetEditorView(),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(
      Document document, BuildContext context) async {
    if (document.currentIsEmpty) return true;
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
