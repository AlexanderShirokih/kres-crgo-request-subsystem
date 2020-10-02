import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:file_chooser/file_chooser.dart';

import 'package:kres_requests2/repo/worksheet_repository.dart';
import 'package:kres_requests2/screens/startup/startup_screen_button.dart';
import 'package:kres_requests2/screens/editor/worksheet_master_screen.dart';
import 'package:kres_requests2/bloc/startup/startup_bloc.dart';

/// Shows startup wizard
class StartupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Начало работы'),
        ),
        body: BlocProvider.value(
          value: StartupBloc(context.repository<WorksheetRepository>()),
          child: Builder(
            builder: (ctx) => BlocConsumer<StartupBloc, StartupState>(
              cubit: ctx.bloc<StartupBloc>(),
              builder: (ctx, state) {
                if (state is StartupLoadingState) {
                  return _StartupLoadingView("Загрузка файла ${state.path}");
                } else if (state is StartupErrorState) {
                  return _StartupErrorView(
                    state.error.toString(),
                    state.stackTrace.toString(),
                  );
                } else // InitialState
                  return _StartupScreenMenu();
              },
              listener: (ctx, state) {
                if (state is StartupShowDocumentState) {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => WorksheetMasterScreen(
                        document: state.document,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
}

class _StartupErrorView extends StatelessWidget {
  final String _errorDescription;
  final String _stackTrace;

  const _StartupErrorView(this._errorDescription, this._stackTrace);

  @override
  Widget build(BuildContext context) => Center(
        child: Card(
          elevation: 5.0,
          margin: EdgeInsets.all(10.0),
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 24.0),
                Text('Ой, кажется произошла ошибка😢',
                    style: Theme.of(context).textTheme.headline6),
                Expanded(
                  child: ListView(
                    children: [
                      Text(_errorDescription,
                          style: Theme.of(context).textTheme.bodyText2),
                      SizedBox(height: 24.0),
                      Text(_stackTrace,
                          style: Theme.of(context).textTheme.bodyText2)
                    ],
                  ),
                ),
                RaisedButton(
                  onPressed: () =>
                      context.bloc<StartupBloc>().add(StartupInitialEvent()),
                  child: Text("НАЗАД"),
                ),
              ],
            ),
          ),
        ),
      );
}

class _StartupLoadingView extends StatelessWidget {
  final String _text;

  const _StartupLoadingView(this._text);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            const SizedBox(height: 10.0),
            Text(_text),
          ],
        ),
      );
}

class _StartupScreenMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StartupScreenButton(
              label: 'Создать новый документ',
              iconData: FontAwesomeIcons.plus,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WorksheetMasterScreen()),
              ),
            ),
            StartupScreenButton(
              label: 'Открыть документ',
              iconData: FontAwesomeIcons.folderOpen,
              onPressed: () {},
            ),
            StartupScreenButton(
              label: 'Импорт заявок',
              iconData: FontAwesomeIcons.fileImport,
              onPressed: () => _showImportDialog(context),
            ),
          ],
        ),
      );
}

Future _showImportDialog(BuildContext context) async {
  final res = await showOpenPanel(
    allowsMultipleSelection: false,
    canSelectDirectories: false,
    initialDirectory: './',
    confirmButtonText: 'Открыть',
    allowedFileTypes: [
      FileTypeFilterGroup(
        label: "Файлы EXCEL",
        fileExtensions: ["xls"],
      )
    ],
  );
  if (res.canceled) return;

  context.bloc<StartupBloc>().add(StartupImportEvent(res.paths[0]));
}
