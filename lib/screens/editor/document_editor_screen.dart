import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/bloc/editor/worksheet_master_bloc.dart';
import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/repo/worksheet_importer_service.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/editor/widgets/worksheet_editor_view.dart';
import 'package:kres_requests2/screens/editor/worksheet_config_view/worksheet_config_view.dart';
import 'package:kres_requests2/screens/importer/counters_importer_screen.dart';
import 'package:kres_requests2/screens/importer/native_import_screen.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';

import 'widgets/worksheet_page_controller.dart';

/// Screen that manages whole document state
class DocumentEditorScreen extends StatelessWidget {
  final Document document;
  final DocumentSaver documentSaver;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  DocumentEditorScreen({
    required this.document,
    required this.documentSaver,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => WorksheetMasterBloc(
          document,
          documentSaver: documentSaver,
          savePathChooser: showSaveDialog,
        ),
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: _buildEndDrawer(),
          appBar: _buildAppBar(),
          body: BlocConsumer<WorksheetMasterBloc, WorksheetMasterState>(
            listener: (context, state) {
              if (state is WorksheetMasterPopState) {
                Navigator.pop(context);
              } else if (state is WorksheetMasterSavingState) {
                _handleSavingState(context, state);
              } else if (state is WorksheetMasterShowImporterState) {
                _onShowImporterScreen(context, state);
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
                Positioned.fill(child: _buildBody(context, state)),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 36.0),
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
        ),
      );

  Widget _buildBody(BuildContext context, WorksheetMasterState state) {
    final document = state.currentDocument;
    return WillPopScope(
      onWillPop: () => _showExitConfirmationDialog(document, context),
      child: Row(
        children: [
          Container(
            width: 285.0,
            height: double.maxFinite,
            child: WorksheetsPageController(document: document),
          ),
          Expanded(
            child: Container(
                color: Color(0xFFE5E5E5),
                height: double.maxFinite,
                child: _buildEditor(document)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor(Document document) {
    return StreamBuilder<Worksheet>(
        stream: document.active,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('Пока здесь нет данных');
          }

          final currentWorksheet = snapshot.requireData;
          return WorksheetEditorView(
            key: ObjectKey(currentWorksheet),
            worksheetEditor: document.edit(currentWorksheet),
            document: document,
            highlighted: Stream.empty(),
            // TODO: Broken
            // highlighted: state is WorksheetMasterSearchingState
            //     ? state.filteredItems[state.currentDocument.active]
            //     : null,
          );
        });
  }

  Widget _buildEndDrawer() =>
      BlocBuilder<WorksheetMasterBloc, WorksheetMasterState>(
        builder: (context, state) => Container(
          width: 420.0,
          child: Drawer(
            child: StreamBuilder<Worksheet>(
                stream: state.currentDocument.active,
                builder: (context, snap) {
                  return snap.hasData
                      ? WorksheetConfigView(
                          Modular.get(),
                          state.currentDocument.edit(snap.requireData),
                        )
                      : Container();
                }),
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
            stream: context.watch<WorksheetMasterBloc>().state.documentTitle,
            builder: (_, snap) => Text(
                'Редактирование - ${snap.data ?? "Несохранённый документ"}'),
          ),
        ),
        actions: [
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.search),
            tooltip: 'Поиск',
            onPressed: (context) => context
                .read<WorksheetMasterBloc>()
                .add(WorksheetMasterSearchEvent()),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.save),
            tooltip: 'Сохранить',
            onPressed: (context) => context
                .read<WorksheetMasterBloc>()
                .add(WorksheetMasterSaveEvent()),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.solidSave),
            tooltip: 'Сохранить как (копия)',
            onPressed: (context) => context
                .read<WorksheetMasterBloc>()
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
                    context.read<WorksheetMasterBloc>().state.currentDocument,
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

  void _onShowImporterScreen(
      BuildContext context, WorksheetMasterShowImporterState state) async {
    final workingDirectory = state.currentDocument.workingDirectory;
    switch (state.importerType) {
      case WorksheetImporterType.requestsImporter:
        // TODO: Replace with modular
        _navigateToImporter(
          context,
          RequestsImporterScreen(
            initialDirectory: workingDirectory,
            targetDocument: state.currentDocument,
            requestsRepository: Modular.get(),
          ),
        );
        break;
      case WorksheetImporterType.countersImporter:
      // TODO: Replace with modular
        _navigateToImporter(
          context,
          CountersImporterScreen(
            initialDirectory: workingDirectory,
            targetDocument: state.currentDocument,
            importerRepository: CountersImporterService(
              importer: CountersImporter(),
              tableChooser: (tables) => showDialog<String>(
                context: context,
                builder: (_) => TableSelectionDialog(tables),
              ),
            ),
          ),
        );
        break;
      case WorksheetImporterType.nativeImporter:
        _navigateToImporter(
          context,
          NativeImporterScreen(
            initialDirectory: workingDirectory,
            targetDocument: state.currentDocument,
            importerRepository:
                NativeImporterService(Modular.get(), (tables) async {
              final worksheets = await showDialog<List<Worksheet>>(
                context: context,
                builder: (_) => SelectWorksheetsDialog(tables),
              );
              return worksheets!;
            }),
          ),
        );
        break;
    }
  }

  Future _navigateToImporter(BuildContext context, Widget importerScreen) =>
      Navigator.push<Document>(
        context,
        MaterialPageRoute(builder: (_) => importerScreen),
      ).then(
        (resultDoc) {
          throw UnimplementedError();
          // context
          //   .read<WorksheetMasterBloc>()
          //   .add(WorksheetMasterImportResultsEvent(resultDoc!));
        },
      );

  Future<bool> _showExitConfirmationDialog(
      Document document, BuildContext context) async {
    if (await document.isEmpty.first) return true;
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
