import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/bloc/worksheets/worksheet_master_bloc.dart';
import 'package:kres_requests2/domain/document_service.dart';
import 'package:kres_requests2/domain/request_set_service.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';
import 'package:kres_requests2/screens/editor/search_box.dart';
import 'package:kres_requests2/screens/editor/worksheet_config_view.dart';
import 'package:kres_requests2/screens/editor/worksheet_editor_screen.dart';
import 'package:kres_requests2/screens/editor/worksheet_tab_view.dart';
import 'package:kres_requests2/screens/importer/counters_importer_screen.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';
import 'package:kres_requests2/screens/preview/worksheets_preview_screen.dart';

class WorksheetMasterScreen extends StatelessWidget {
  final DocumentService _documentService;
  final WorksheetMasterBloc _worksheetBloc;
  final RepositoryModule _repositoryModule;

  WorksheetMasterScreen({
    @required RepositoryModule repositoryModule,
    @required DocumentService documentService,
  })  : _worksheetBloc = WorksheetMasterBloc(documentService),
        _documentService = documentService,
        _repositoryModule = repositoryModule;

  @override
  Widget build(BuildContext context) => Scaffold(
        endDrawer: _buildEndDrawer(),
        appBar: _buildAppBar(),
        body: BlocConsumer<WorksheetMasterBloc, WorksheetMasterState>(
          cubit: _worksheetBloc,
          listener: (context, state) {
            if (state is WorksheetMasterPopState) {
              Navigator.pop(context);
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

  Widget _buildBody(BuildContext context, WorksheetMasterState state) => Row(
        children: [
          _createPageController(context, state),
          Expanded(
            child: Container(
              height: double.maxFinite,
              child: WorkSheetEditorView(
                documentService: _documentService,
                requestSetService: _documentService.getEditableWorksheet(),
                onDocumentsChanged: () => _worksheetBloc
                    .add(WorksheetMasterRefreshDocumentStateEvent()),
                highlighted: state is WorksheetMasterSearchingState
                    ? state.filteredItems[state.active]
                    : null,
              ),
            ),
          ),
        ],
      );

  Widget _buildEndDrawer() =>
      BlocBuilder<WorksheetMasterBloc, WorksheetMasterState>(
        cubit: _worksheetBloc,
        builder: (context, state) => Container(
          width: 420.0,
          child: Drawer(
            child: WorksheetConfigView(
              _repositoryModule,
              _documentService.getEditableWorksheet(),
            ),
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
          builder: (_, state) {
            if (state is WorksheetMasterIdleState) {
              return Text('Редактирование - ${state.currentEditable.name}');
            } else
              return Text('...');
          },
        ),
        actions: [
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.search),
            tooltip: "Поиск",
            onPressed: (_) => _worksheetBloc.add(WorksheetMasterSearchEvent()),
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
                        WorksheetsPreviewScreen(_documentService),
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
    final worksheets = _documentService.getEditableWorksheets();

    Widget withClosure(RequestSetService current,
            Widget Function(RequestSetService) closure) =>
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
            ? AddNewWorkSheetTabView((worksheetCreationMode) =>
                _worksheetBloc.add(
                    WorksheetMasterAddNewWorksheetEvent(worksheetCreationMode)))
            : withClosure(
                worksheets[index],
                (current) => WorkSheetTabView(
                  worksheet: current,
                  filteredItemsCount: state is WorksheetMasterSearchingState
                      ? state.filteredItems[current.getRequestSet()]?.length ??
                          0
                      : 0,
                  isActive:
                      current.getRequestSet() == _documentService.getActive(),
                  onSelect: () => _worksheetBloc.add(
                      WorksheetMasterWorksheetActionEvent(
                          current, WorksheetAction.makeActive)),
                  onRemove: worksheets.length == 1
                      ? null
                      : () {
                          if (!current.isEmpty) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              child: ConfirmationDialog(
                                message:
                                    "Удалить страницу ${current.getName()}?",
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

  void _onShowImporterScreen(
      BuildContext context, WorksheetMasterShowImporterState state) {
    switch (state.importerType) {
      case WorksheetImporterType.requestsImporter:
        _navigateToImporter(
          context,
          RequestsImporterScreen.fromContext(
            context: context,
            targetDocument: _documentService,
            repositoryModule: _repositoryModule,
          ),
        );
        break;
      //
      case WorksheetImporterType.countersImporter:
        _navigateToImporter(
          context,
          CountersImporterScreen(
            targetDocument: _documentService,
            importerRepository:
                _repositoryModule.getCountersImporterRepository(),
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
        (resultDoc) => throw UnimplementedError(),
      );
}
