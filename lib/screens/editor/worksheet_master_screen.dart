import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/common/worksheet_creation_mode.dart';

import 'package:kres_requests2/data/document.dart';
import 'package:kres_requests2/data/worksheet.dart';
import 'package:kres_requests2/screens/confirmation_dialog.dart';
import 'package:kres_requests2/screens/editor/worksheet_config_view.dart';
import 'package:kres_requests2/screens/editor/worksheet_tab_view.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';

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

  _WorksheetMasterScreenState(Document currentDocument)
      : _currentDocument = currentDocument ?? Document.empty();

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
          IconButton(
            icon: FaIcon(FontAwesomeIcons.save),
            tooltip: "Сохранить",
            onPressed: () {
              // TODO: Save current document
            },
          ),
          const SizedBox(width: 24.0),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.solidSave),
            tooltip: "Сохранить как",
            onPressed: () {
              // TODO: Save current document
            },
          ),
          const SizedBox(width: 24.0),
          IconButton(
            icon: FaIcon(FontAwesomeIcons.fileExport),
            tooltip: "Вывод",
            onPressed: () {
              // TODO: Navigate to print dialog
            },
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
            ? AddNewWorkSheetTabView(
                (WorksheetCreationMode mode) {
                  switch (mode) {
                    case WorksheetCreationMode.Import:
                      Navigator.push<Document>(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => RequestsImporterScreen.fromContext(
                            context: ctx,
                            targetDocument: _currentDocument,
                          ),
                        ),
                      ).then(
                        (resultDoc) => setState(() {
                          if (resultDoc != null)
                            resultDoc.active = resultDoc.worksheets.last;
                        }),
                      );
                      break;
                    case WorksheetCreationMode.EmptyRaid:
                    case WorksheetCreationMode.ImportCounters:
                    case WorksheetCreationMode.Empty:
                    default:
                      setState(() {
                        _currentDocument.active =
                            _currentDocument.addEmptyWorksheet();
                      });
                  }
                },
              )
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
}
