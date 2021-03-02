import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/app_module.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/editor/worksheet_master_screen.dart';
import 'package:kres_requests2/screens/importer/native_import_screen.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';
import 'package:kres_requests2/screens/settings/settings_screen.dart';
import 'package:kres_requests2/screens/startup/startup_module.dart';
import 'package:kres_requests2/screens/startup/startup_screen_button.dart';
import 'package:window_control/window_listener.dart';

/// Shows startup wizard
class StartupScreen extends StatelessWidget {
  final StartupModule _startupModule;

  StartupScreen({
    Key key,
    @required AppModule appModule,
  })  : _startupModule = StartupModule(appModule),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Начало работы'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: FaIcon(FontAwesomeIcons.cog),
                onPressed: () => Navigator.push(
                  context,
                  SettingsScreen.createRoute(
                    context.repository<RepositoryModule>(),
                    _startupModule.settingsModule,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: WindowListener(
          onWindowClosing: () => Future.value(true),
          child: Center(
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NativeImporterScreen(
                        importAll: true,
                        importerRepository: context
                            .repository<RepositoryModule>()
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
        ),
      );

  Future _runWorksheetEditorScreen(
          BuildContext context, Document targetDocument) =>
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorksheetMasterScreen(
            employeeModule: _startupModule.settingsModule.employeeModule,
            document: targetDocument,
          ),
        ),
      );
}
