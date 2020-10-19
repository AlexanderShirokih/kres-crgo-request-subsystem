import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:window_control/window_listener.dart';

import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/bloc/worksheets/worksheet_master_bloc.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';
import 'package:kres_requests2/screens/editor/search_box.dart';
import 'package:kres_requests2/screens/editor/worksheet_editor_screen.dart';
import 'package:kres_requests2/screens/editor/worksheet_config_view.dart';
import 'package:kres_requests2/screens/editor/worksheet_tab_view.dart';
import 'package:kres_requests2/screens/importer/native_import_screen.dart';
import 'package:kres_requests2/screens/importer/counters_importer_screen.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';
import 'package:kres_requests2/screens/preview/worksheets_preview_screen.dart';

class WorksheetMasterScreen extends StatelessWidget {
  final WorksheetMasterBloc _worksheetBloc;

  WorksheetMasterScreen({Document document})
      : _worksheetBloc =
            WorksheetMasterBloc(document, savePathChooser: showSaveDialog);

  String _getDocumentTitle(Document document) => document.savePath == null
      ? "Несохранённый документ"
      : document.savePath.path;

  @override
  Widget build(BuildContext context) => Scaffold(
        endDrawer: _buildEndDrawer(),
        appBar: _buildAppBar(),
        body: BlocConsumer<WorksheetMasterBloc, WorksheetMasterState>(
          cubit: _worksheetBloc,
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
            if (state is WorksheetMasterSearchingState) {
              return Stack(children: [
                Positioned.fill(child: _buildBody(context, state)),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, right: 12.0),
                    child: SearchBox(
                      textWatcher: (String searchText) => _worksheetBloc
                          .add(WorksheetMasterSearchEvent(searchText)),
                    ),
                  ),
                ),
              ]);
            } else {
              return _buildBody(context, state);
            }
          },
        ),
      );

  Widget _buildBody(BuildContext context, WorksheetMasterState state) =>
      WindowListener(
        onWindowClosing: () =>
            _showExitConfirmationDialog(state.currentDocument, context),
        child: WillPopScope(
          onWillPop: () =>
              _showExitConfirmationDialog(state.currentDocument, context),
          child: Row(
            children: [
              _createPageController(context, state),
              Expanded(
                child: Container(
                  height: double.maxFinite,
                  child: WorkSheetEditorView(
                    document: state.currentDocument,
                    worksheet: state.currentDocument.active,
                    onDocumentsChanged: () => _worksheetBloc
                        .add(WorksheetMasterRefreshDocumentStateEvent()),
                    highlighted: state is WorksheetMasterSearchingState
                        ? state.filteredItems[state.currentDocument.active]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildEndDrawer() =>
      BlocBuilder<WorksheetMasterBloc, WorksheetMasterState>(
        cubit: _worksheetBloc,
        builder: (context, state) => Container(
          width: 420.0,
          child: Drawer(
            child: WorksheetConfigView(state.currentDocument.active),
          ),
        ),
      );

  AppBar _buildAppBar() => AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: FaIcon(FontAwesomeIcons.arrowLeft),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        title: BlocBuilder<WorksheetMasterBloc, WorksheetMasterState>(
          cubit: _worksheetBloc,
          builder: (_, state) => Text(
              'Редактирование - ${_getDocumentTitle(state.currentDocument)}'),
        ),
        actions: [
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.search),
            tooltip: "Поиск",
            onPressed: (_) => _worksheetBloc.add(WorksheetMasterSearchEvent()),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.save),
            tooltip: "Сохранить",
            onPressed: (_) => _worksheetBloc.add(WorksheetMasterSaveEvent()),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.solidSave),
            tooltip: "Сохранить как (копия)",
            onPressed: (_) =>
                _worksheetBloc.add(WorksheetMasterSaveEvent(changePath: true)),
          ),
          const SizedBox(width: 24.0),
          Builder(
            builder: (context) => IconButton(
              icon: FaIcon(FontAwesomeIcons.fileExport),
              tooltip: "Вывод",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BlocBuilder<WorksheetMasterBloc, WorksheetMasterState>(
                    cubit: _worksheetBloc,
                    builder: (context, state) =>
                        WorksheetsPreviewScreen(state.currentDocument),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24.0),
        ],
      );

  Widget _createActionButton({
    Widget icon,
    String tooltip,
    void Function(BuildContext) onPressed,
  }) =>
      Builder(
        builder: (ctx) => IconButton(
          icon: icon,
          tooltip: tooltip,
          onPressed: () => onPressed(ctx),
        ),
      );

  Widget _createPageController(
      BuildContext context, WorksheetMasterState state) {
    Widget withClosure(Worksheet current, Widget Function(Worksheet) closure) =>
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
        itemCount: state.currentDocument.worksheets.length + 1,
        itemBuilder: (context, index) => index ==
                state.currentDocument.worksheets.length
            ? AddNewWorkSheetTabView((worksheetCreationMode) =>
                _worksheetBloc.add(
                    WorksheetMasterAddNewWorksheetEvent(worksheetCreationMode)))
            : withClosure(
                state.currentDocument.worksheets[index],
                (current) => WorkSheetTabView(
                  worksheet: current,
                  filteredItemsCount: state is WorksheetMasterSearchingState
                      ? state.filteredItems[current]?.length ?? 0
                      : 0,
                  isActive: current == state.currentDocument.active,
                  onSelect: () => _worksheetBloc.add(
                      WorksheetMasterWorksheetActionEvent(
                          current, WorksheetAction.makeActive)),
                  onRemove: state.currentDocument.worksheets.length == 1
                      ? null
                      : () {
                          if (!current.isEmpty) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: ConfirmationDialog(
                                message: "Удалить страницу ${current.name}?",
                              ),
                            ).then((result) {
                              if (result)
                                _worksheetBloc.add(
                                    WorksheetMasterWorksheetActionEvent(
                                        current, WorksheetAction.remove));
                            });
                          } else
                            _worksheetBloc.add(
                                WorksheetMasterWorksheetActionEvent(
                                    current, WorksheetAction.remove));
                        },
                ),
              ),
      ),
    );
  }

  void _handleSavingState(
      BuildContext context, WorksheetMasterSavingState state) {
    final scaffold = Scaffold.of(context, nullOk: true);
    void showSnackbar(String message, Duration duration) =>
        scaffold?.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
          ),
        );

    scaffold?.removeCurrentSnackBar();
    if (state.error != null) {
      print("${state.error.error}\n${state.error.stackTrace}");
      showSnackbar(
        'Не удалось сохранить! ${state.error.error}',
        const Duration(seconds: 6),
      );
    } else if (state.completed) {
      showSnackbar(
        'Документ сохранён',
        const Duration(seconds: 2),
      );
    } else {
      showSnackbar('Сохранение...', const Duration(seconds: 20));
    }
  }

  void _onShowImporterScreen(
      BuildContext context, WorksheetMasterShowImporterState state) {
    switch (state.importerType) {
      case WorksheetImporterType.requestsImporter:
        _navigateToImporter(
          context,
          RequestsImporterScreen.fromContext(
            initialDirectory: state.currentDirectory,
            targetDocument: state.currentDocument,
            context: context,
          ),
        );
        break;
      //
      case WorksheetImporterType.countersImporter:
        _navigateToImporter(
          context,
          CountersImporterScreen(
            initialDirectory: state.currentDirectory,
            targetDocument: state.currentDocument,
            importerRepository: context
                .repository<RepositoryModule>()
                .getCountersImporterRepository(),
          ),
        );
        break;
      case WorksheetImporterType.nativeImporter:
        _navigateToImporter(
          context,
          NativeImporterScreen(
            initialDirectory: state.currentDirectory,
            targetDocument: state.currentDocument,
            importerRepository: context
                .repository<RepositoryModule>()
                .getNativeImporterRepository(),
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
        (resultDoc) =>
            _worksheetBloc.add(WorksheetMasterImportResultsEvent(resultDoc)),
      );

  Future<bool> _showExitConfirmationDialog(
      Document document, BuildContext context) async {
    if (document.isEmpty) return true;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Сохранить документ перед выходом?'),
        actionsPadding: EdgeInsets.only(right: 24.0, bottom: 12.0),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Отмена'),
          ),
          const SizedBox(width: 12.0),
          FlatButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Нет'),
          ),
          const SizedBox(width: 12.0),
          RaisedButton(
            color: Theme.of(ctx).primaryColor,
            textColor: Theme.of(ctx).primaryTextTheme.bodyText2.color,
            onPressed: () => _worksheetBloc
                .add(WorksheetMasterSaveEvent(popAfterSave: true)),
            child: Text('Да'),
          ),
        ],
      ),
    );
  }
}
