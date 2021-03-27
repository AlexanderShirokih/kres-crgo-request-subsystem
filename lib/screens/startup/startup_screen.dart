import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/screens/startup/startup_screen_button.dart';

/// Shows startup wizard
class StartupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Начало работы'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: FaIcon(FontAwesomeIcons.cog),
                onPressed: () => Modular.to.pushNamed('/settings'),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StartupScreenButton(
                label: 'Создать новый документ',
                iconData: FontAwesomeIcons.plus,
                onPressed: () =>
                    _runWorksheetEditorScreen(context, Document.empty()),
              ),
              StartupScreenButton(
                label: 'Открыть документ',
                iconData: FontAwesomeIcons.folderOpen,
                onPressed: () {
                  Modular.to
                      .pushNamed<Document>('/document/open')
                      .then((resultDocument) {
                    if (resultDocument != null) {
                      return _runWorksheetEditorScreen(context, resultDocument);
                    }
                  });
                },
              ),
              StartupScreenButton(
                label: 'Импорт заявок',
                iconData: FontAwesomeIcons.fileImport,
                onPressed: () {
                  Modular.to
                      .pushNamed<Document>('/document/import/requests',
                          arguments: Document.empty())
                      .then((resultDocument) {
                    if (resultDocument != null)
                      return _runWorksheetEditorScreen(context, resultDocument);
                  });
                },
              ),
            ],
          ),
        ),
      );

  Future _runWorksheetEditorScreen(
          BuildContext context, Document targetDocument) =>
      Modular.to.pushNamed('/document/edit', arguments: targetDocument);
}
