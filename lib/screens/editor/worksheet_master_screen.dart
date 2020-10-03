import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

import 'package:kres_requests2/common/worksheet_creation_mode.dart';
import 'package:kres_requests2/common/worksheet_importer.dart';
import 'package:kres_requests2/core/counters_importer.dart';
import 'package:kres_requests2/data/document.dart';
import 'package:kres_requests2/data/worksheet.dart';
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

class _WorksheetMasterScreenState extends State<WorksheetMasterScreen> {
  final Document _currentDocument;
  String _currentDirectory;

  _WorksheetMasterScreenState(Document currentDocument)
      : _currentDocument = currentDocument ??= Document.empty(),
        _currentDirectory = currentDocument.savePath == null
            ? './'
            : path.dirname(currentDocument.savePath.path);

  String _getDocumentName() => _currentDocument.savePath == null
      ? "Несохранённый документ"
      : _currentDocument.savePath.path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Container(
        width: 420.0,
        child: Drawer(
          child: WorksheetConfigView(_currentDocument.active),
        ),
      ),
      appBar: AppBar(
        title: Text('Редактирование - ${_getDocumentName()}'),
        actions: [
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.save),
            tooltip: "Сохранить",
            onPressed: (ctx) => _saveDocument(ctx, false),
          ),
          const SizedBox(width: 24.0),
          _createActionButton(
            icon: FaIcon(FontAwesomeIcons.solidSave),
            tooltip: "Сохранить под новым именем (копия)",
            onPressed: (ctx) => _saveDocument(ctx, true),
          ),
          const SizedBox(width: 24.0),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.fileExport),
            tooltip: "Вывод",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorksheetsPreviewScreen(_currentDocument),
              ),
            ),
          ),
          const SizedBox(width: 24.0),
        ],
      ),
      body: Row(
        children: [
          _createPageController(),
          Expanded(
            child: Container(
              height: double.maxFinite,
              child: WorkSheetEditorView(
                document: _currentDocument,
                worksheet: _currentDocument.active,
                onDocumentsChanged: () => setState(() {}),
              ),
            ),
          ),
        ],
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
        itemCount: _currentDocument.worksheets.length + 1,
        itemBuilder: (_, index) => index == _currentDocument.worksheets.length
            ? AddNewWorkSheetTabView(_handleAddNewScreen)
            : withClosure(
                _currentDocument.worksheets[index],
                (current) => WorkSheetTabView(
                  worksheet: current,
                  isActive: current == _currentDocument.active,
                  onSelect: () => setState(() {
                    _currentDocument.active = current;
                  }),
                  onRemove: _currentDocument.worksheets.length == 1
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
                                    _currentDocument.removeWorksheet(current));
                            });
                          } else
                            setState(() =>
                                _currentDocument.removeWorksheet(current));
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
            context: context,
            targetDocument: _currentDocument,
          ),
        );
        break;
      case WorksheetCreationMode.ImportCounters:
        _navigateToImporter(
          context,
          CountersImporterScreen(
            targetDocument: _currentDocument,
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
      // TODO: Implement feature
      case WorksheetCreationMode.EmptyRaid:
      case WorksheetCreationMode.Empty:
      default:
        setState(() {
          _currentDocument.active = _currentDocument.addEmptyWorksheet();
        });
    }
  }

  Future _navigateToImporter(BuildContext context, Widget importerScreen) =>
      Navigator.push<Document>(
        context,
        MaterialPageRoute(builder: (_) => importerScreen),
      ).then(
        (resultDoc) => setState(() {
          if (resultDoc != null) resultDoc.active = resultDoc.worksheets.last;
        }),
      );

  Future _saveDocument(BuildContext context, bool changePath) async {
    if (_currentDocument.savePath == null || changePath) {
      final newSavePath = await _showSaveDialog();
      if (newSavePath == null) return;

      setState(() {
        _currentDocument.savePath = newSavePath;
      });
    }

    final scaffold = Scaffold.of(context);

    void showSnackbar(String message, Duration duration) =>
        scaffold.showSnackBar(
          SnackBar(
            content: Text(message),
            duration: duration,
          ),
        );

    showSnackbar('Сохранение...', const Duration(hours: 1));

    _currentDocument.save().then((_) {
      scaffold.removeCurrentSnackBar();
      showSnackbar(
        'Документ сохранён',
        const Duration(seconds: 2),
      );
    }).catchError(
      (e, s) {
        print("$e\n$s");
        scaffold.removeCurrentSnackBar();
        showSnackbar(
          'Не удалось сохранить! $e',
          const Duration(seconds: 6),
        );
      },
    );
  }

  Future<File> _showSaveDialog() async {
    final res = await showSavePanel(
      initialDirectory: _currentDirectory,
      confirmButtonText: 'Сохранить',
      allowedFileTypes: [
        FileTypeFilterGroup(
          label: "Документ работы",
          fileExtensions: ["json"],
        )
      ],
    );
    if (res.canceled) return null;

    final savePath = res.paths[0];
    _currentDirectory = path.dirname(savePath);
    return File(savePath);
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
