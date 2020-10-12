import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/screens/title_bar.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/importer/native_import_screen.dart';
import 'package:path/path.dart' as path;

// TODO: Replace domain layer with repository
import 'package:kres_requests2/domain/worksheet_creation_mode.dart';
import 'package:kres_requests2/domain/worksheet_importer.dart';
import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/worksheet.dart';
import 'package:kres_requests2/repo/config_repository.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';
import 'package:kres_requests2/screens/editor/worksheet_config_view.dart';
import 'package:kres_requests2/screens/editor/worksheet_tab_view.dart';
import 'package:kres_requests2/screens/importer/counters_importer_screen.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';
import 'package:kres_requests2/screens/preview/worksheets_preview_screen.dart';

import 'worksheet_editor_screen.dart';

class WorksheetMasterScreen extends StatefulWidget {
  final Document document;

  const WorksheetMasterScreen({this.document});

  @override
  _WorksheetMasterScreenState createState() =>
      _WorksheetMasterScreenState(document);
}

class _WorksheetMasterScreenState extends State<WorksheetMasterScreen>
    with DocumentSaverMixin<WorksheetMasterScreen> {
  @override
  Document currentDocument;

  @override
  String currentDirectory;

  _WorksheetMasterScreenState(Document currentDocument)
      : this.currentDocument = currentDocument ??= Document.empty(),
        currentDirectory = currentDocument.savePath == null
            ? './'
            : path.dirname(currentDocument.savePath.path);

  String _getDocumentTitle() => currentDocument.savePath == null
      ? "Несохранённый документ"
      : currentDocument.savePath.path;

  @override
  void dispose() {
    TitleBarBindings.instance.unregisterClosingCallback();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TitleBarBindings.instance
        .registerClosingCallback(() => _showExitConfirmationDialog(context));
    return Scaffold(
      endDrawer: Container(
        width: 420.0,
        child: Drawer(
          child: WorksheetConfigView(currentDocument.active),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text('Редактирование - ${_getDocumentTitle()}'),
        actions: [
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.save),
            tooltip: "Сохранить",
            onPressed: (ctx) => saveDocument(ctx, false),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.solidSave),
            tooltip: "Сохранить как (копия)",
            onPressed: (ctx) => saveDocument(ctx, true),
          ),
          const SizedBox(width: 24.0),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.fileExport),
            tooltip: "Вывод",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorksheetsPreviewScreen(currentDocument),
              ),
            ),
          ),
          const SizedBox(width: 24.0),
        ],
      ),
      body: Builder(
        builder: (ctx) => WillPopScope(
          onWillPop: () => _showExitConfirmationDialog(ctx),
          child: Row(
            children: [
              _createPageController(),
              Expanded(
                child: Container(
                  height: double.maxFinite,
                  child: WorkSheetEditorView(
                    document: currentDocument,
                    worksheet: currentDocument.active,
                    onDocumentsChanged: () => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _createPageController() {
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
        itemCount: currentDocument.worksheets.length + 1,
        itemBuilder: (_, index) => index == currentDocument.worksheets.length
            ? AddNewWorkSheetTabView(_handleAddNewScreen)
            : withClosure(
                currentDocument.worksheets[index],
                (current) => WorkSheetTabView(
                  worksheet: current,
                  isActive: current == currentDocument.active,
                  onSelect: () => setState(() {
                    currentDocument.active = current;
                  }),
                  onRemove: currentDocument.worksheets.length == 1
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
                                setState(() =>
                                    currentDocument.removeWorksheet(current));
                            });
                          } else
                            setState(
                                () => currentDocument.removeWorksheet(current));
                        },
                ),
              ),
      ),
    );
  }

  void _handleAddNewScreen(WorksheetCreationMode mode) {
    switch (mode) {
      case WorksheetCreationMode.Import:
        _navigateToImporter(
          context,
          RequestsImporterScreen.fromContext(
            initialDirectory: currentDirectory,
            context: context,
            targetDocument: currentDocument,
          ),
        );
        break;
      case WorksheetCreationMode.ImportCounters:
        _navigateToImporter(
          context,
          CountersImporterScreen(
            targetDocument: currentDocument,
            initialDirectory: currentDirectory,
            importer: CountersWorksheetImporter(
              importer:
                  CountersImporter(context.repository<ConfigRepository>()),
              tableChooser: (tables) => showDialog<String>(
                context: context,
                builder: (_) => _TableSelectionDialog(tables),
              ),
            ),
          ),
        );
        break;
      case WorksheetCreationMode.ImportNative:
        _navigateToImporter(
          context,
          NativeImporterScreen(
            targetDocument: currentDocument,
            initialDirectory: currentDirectory,
            multiTableChooser: (tables) => showDialog<List<Worksheet>>(
              context: context,
              builder: (_) => SelectWorksheetsDialog(tables),
            ),
          ),
        );
        break;
      // TODO: Implement feature
      case WorksheetCreationMode.EmptyRaid:
      case WorksheetCreationMode.Empty:
      default:
        setState(() {
          currentDocument.active = currentDocument.addEmptyWorksheet();
        });
    }
  }

  Future _navigateToImporter(BuildContext context, Widget importerScreen) =>
      Navigator.push<Document>(
        context,
        MaterialPageRoute(builder: (_) => importerScreen),
      ).then(
        (resultDoc) => setState(() {
          if (resultDoc != null) {
            currentDocument = resultDoc;
            currentDocument.active = currentDocument.worksheets.last;
          }
        }),
      );

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    if (currentDocument.isEmpty) return true;

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
            onPressed: () => saveDocument(ctx, false).then(
              (save) => Navigator.pop(ctx, save != null),
            ),
            child: Text('Да'),
          ),
        ],
      ),
    );
  }
}

class _TableSelectionDialog extends StatelessWidget {
  final List<String> choices;

  const _TableSelectionDialog(this.choices) : assert(choices != null);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Выберите таблицу для импорта'),
      content: SizedBox(
        width: 300.0,
        height: 440.0,
        child: ListView(
          children: choices
              .map(
                (e) => ListTile(
                  leading: FaIcon(FontAwesomeIcons.table),
                  title: Text(e),
                  onTap: () => Navigator.pop(context, e),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
