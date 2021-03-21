import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/importer/native_import_screen.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NativeImporterScreen(
                      importAll: true,
                      importerRepository: context
                          .watch<RepositoryModule>()
                          .getNativeImporterRepository(),
                    ),
                  ),
                ).then((resultDocument) {
                  if (resultDocument != null)
                    return _runWorksheetEditorScreen(context, resultDocument);
                }),
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
      Modular.to.pushNamed('/document', arguments: targetDocument);
}
