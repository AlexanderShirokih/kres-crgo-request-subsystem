import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/document.dart';

import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';
import 'package:kres_requests2/screens/startup/startup_screen_button.dart';
import 'package:kres_requests2/screens/editor/worksheet_master_screen.dart';

/// Shows startup wizard
class StartupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Начало работы'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StartupScreenButton(
                label: 'Создать новый документ',
                iconData: FontAwesomeIcons.plus,
                onPressed: () => _runWorksheetEditorScreen(context, null),
              ),
              StartupScreenButton(
                label: 'Открыть документ',
                iconData: FontAwesomeIcons.folderOpen,
                onPressed: () {},
              ),
              StartupScreenButton(
                label: 'Импорт заявок',
                iconData: FontAwesomeIcons.fileImport,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => RequestsImporterScreen.fromContext(
                      context: ctx,
                      targetDocument: Document(worksheets: []),
                    ),
                  ),
                ).then((resultDocument) {
                  if (resultDocument != null)
                    return _runWorksheetEditorScreen(context, resultDocument);
                }),
              ),
            ],
          ),
        ),
      );

  Future _runWorksheetEditorScreen(
          BuildContext context, Document targetDocument) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorksheetMasterScreen(
            document: targetDocument,
          ),
        ),
      );
}
