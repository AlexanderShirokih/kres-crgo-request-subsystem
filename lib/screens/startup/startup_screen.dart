import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/models/request_set.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/common/date_chooser.dart';
import 'package:kres_requests2/screens/editor/worksheet_master_screen.dart';
import 'package:kres_requests2/screens/startup/date_tree_view.dart';
import 'package:window_control/window_listener.dart';

import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/settings/settings_screen.dart';
import 'package:kres_requests2/screens/startup/startup_screen_buttons.dart';
import 'package:kres_requests2/bloc/startup/startup_bloc.dart';

/// Startup screen that shows recently opened request sets and
/// provides access to settings screen and ability to create new requests, set
/// or manage them
class StartupScreen extends StatelessWidget {
  final StartupBloc _startupBloc;

  StartupScreen({
    Key key,
    @required RepositoryModule repositoryModule,
  })  : assert(repositoryModule != null),
        _startupBloc = StartupBloc(
          repositoryModule.getUserRepository(),
          repositoryModule.getRequestSetRepository(),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Начало работы'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: BlocBuilder<StartupBloc, StartupState>(
                cubit: _startupBloc,
                builder: (context, state) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.user.name),
                    const SizedBox(width: 16.0),
                    IconButton(
                      icon: FaIcon(FontAwesomeIcons.cog),
                      onPressed: () {
                        // TODO: Implement new settings screen
                        return Navigator.push(
                          context,
                          SettingsScreen.createRoute(
                              context.watch<RepositoryModule>()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: WindowListener(
          onWindowClosing: () => Future.value(true),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _createGroupTitle(context, 'Действия'),
                  _createMainActionsButtons(context),
                  _createGroupTitle(context, 'Последние'),
                  _createRecentlyOpenedItems(),
                  BlocListener(listener: (context, state) {
                    if (state is StartupOpenRequestsSetState) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorksheetMasterScreen(
                            requestSet: state.target,
                          ),
                        ),
                      );
                    }
                  }),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _createGroupTitle(BuildContext context, String groupTitle) => Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 0.0, 12.0),
        child: Text(
          groupTitle,
          style: Theme.of(context).textTheme.headline4,
        ),
      );

  Widget _createMainActionsButtons(BuildContext context) {
    return _createExtendedGrid([
      StartupScreenButtonContainer(
        onPressed: () => _pickDate(context),
        child: SimpleTextStartupTile(
          title: 'Новый документ',
          description: 'Создать новый набор заявок на заданный день',
          iconData: FontAwesomeIcons.plus,
        ),
      ),
      StartupScreenButtonContainer(
        onPressed: () => _pickRequestsSet(context),
        child: SimpleTextStartupTile(
          title: 'Открыть документ',
          description: 'Открыть ранее созданный набор заявок',
          iconData: FontAwesomeIcons.folderOpen,
        ),
      ),
      StartupScreenButtonContainer(
        onPressed: () => _startupBloc.add(StartupCreateNewRequestsSet(
            null, RequestsSetSource.ImportMegaBilling)),
        child: SimpleTextStartupTile(
          title: 'Импорт заявок',
          description:
              'Создать новый документ из подготовленного файла системы mega-billing',
          iconData: FontAwesomeIcons.fileImport,
        ),
      ),
    ]);
  }

  Widget _createRecentlyOpenedItems() => BlocBuilder<StartupBloc, StartupState>(
        cubit: _startupBloc,
        builder: (context, state) {
          if (state is StartupFetchingRecent) {
            return LoadingView('Загрузка последних документов');
          } else if (state is StartupGotRecentDocuments) {
            if (state.requests.isEmpty) {
              return _createRefreshableTitle(
                  context, 'Список последних документов пуст');
            } else {
              return _showRecentlyOpenedItems(state.requests, state.hasMore);
            }
          } else if (state is StartupFetchingError) {
            return _createRefreshableTitle(context,
                'Не удалось загрузить данные. Проверьте соединение с сервером.');
          } else
            return LoadingView();
        },
      );

  Widget _createRefreshableTitle(BuildContext context, String title) => Center(
        child: Column(
          children: [
            _RefreshButton(
              onPressed: () => _startupBloc.add(StartupFetchRecent()),
            ),
            const SizedBox(height: 16.0),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      );

  Widget _createExtendedGrid(List<StartupScreenButtonContainer> children) {
    return Expanded(
      flex: min(2, (children.length / 3.0).floor()),
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          height: min(1000000,
              245.0 * min((children.length / 3.0).ceilToDouble(), 2.0)),
          child: GridView.count(
            crossAxisCount: 3,
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _showRecentlyOpenedItems(List<RequestSet> requestSet, bool hasMore) {
    return _createExtendedGrid([
      ...requestSet
          .map(
            (e) => StartupScreenButtonContainer(
              onPressed: () => _startupBloc.add(StartupOpenRequestsSet(e)),
              child: RequestSetDescriptionTile(
                name: e.name ?? '???',
                targetDate: e.date,
              ),
            ),
          )
          .toList(),
      if (hasMore)
        StartupScreenButtonContainer(
          onPressed: () => _startupBloc.add(StartupFetchRecent(true)),
          child: SimpleTextStartupTile(
            title: '',
            description: 'Загрузить ещё',
            iconData: FontAwesomeIcons.ellipsisH,
          ),
        ),
    ]);
  }

  void _pickRequestsSet(BuildContext context) => showDialog<RequestSet>(
        context: context,
        child: Container(
          width: 400,
          height: 600,
          child: DateTreeView(
            requestsSetRepository: _startupBloc.requestSetRepository,
          ),
        ),
      ).then((request) {
        if (request != null) _startupBloc.add(StartupOpenRequestsSet(request));
      });

  void _pickDate(BuildContext context) =>
      showDialog<DateTime>(context: context, child: DateChooserDialog())
          .then((chosenDate) {
        if (chosenDate != null)
          _startupBloc.add(
              StartupCreateNewRequestsSet(chosenDate, RequestsSetSource.New));
      });
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RefreshButton({Key key, @required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          FaIcon(FontAwesomeIcons.sync),
          Text('Обновить'),
        ]),
      ),
    );
  }
}
