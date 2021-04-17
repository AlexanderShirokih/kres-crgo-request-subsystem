import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/domain/models/recent_document_info.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/bloc/startup/recent_docs_bloc.dart';
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
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 700.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _createGroupTitle(context, 'Действия'),
                _createMainActionsButtons(context),
                _createGroupTitle(context, 'Последние'),
                _createRecentlyOpenedItems(),
              ],
            ),
          ),
        ),
      );

  Widget _createGroupTitle(BuildContext context, String groupTitle) => Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 24.0, 0.0, 12.0),
        child: Text(
          groupTitle,
          style: Theme.of(context).textTheme.headline4,
        ),
      );

  Widget _createMainActionsButtons(BuildContext context) {
    return SizedBox(
      height: 250.0,
      child: GridView.count(
        crossAxisCount: 3,
        children: [
          StartupScreenButtonContainer(
            onPressed: () => _runWorksheetEditorScreen(Document.empty()),
            child: TextStartupTile(
              title: 'Новый документ',
              description: 'Создать новый пустой документ заявок',
              iconData: FontAwesomeIcons.plus,
            ),
          ),
          StartupScreenButtonContainer(
            onPressed: () {
              Modular.to
                  .pushNamed<Document>('/document/open')
                  .then((resultDocument) {
                if (resultDocument != null) {
                  return _runWorksheetEditorScreen(resultDocument);
                }
              });
            },
            child: TextStartupTile(
              title: 'Открыть документ',
              description: 'Открыть ранее созданный документ заявок',
              iconData: FontAwesomeIcons.solidFolderOpen,
            ),
          ),
          StartupScreenButtonContainer(
            onPressed: () {
              Modular.to
                  .pushNamed<Document>('/document/import/requests',
                      arguments: Document.empty())
                  .then((resultDocument) {
                if (resultDocument != null)
                  return _runWorksheetEditorScreen(resultDocument);
              });
            },
            child: TextStartupTile(
              title: 'Импорт заявок',
              description:
                  'Создать новый документ из подготовленного файла системы mega-billing',
              iconData: FontAwesomeIcons.fileImport,
            ),
          ),
        ],
      ),
    );
  }

  Future _runWorksheetEditorScreen(Document targetDocument) =>
      Modular.to.pushNamed('/document/edit', arguments: targetDocument);

  Widget _createRecentlyOpenedItems() {
    return BlocProvider(
      create: (_) => RecentDocumentsBloc(Modular.get()),
      child: BlocBuilder<RecentDocumentsBloc, RecentDocsState>(
        builder: (context, state) {
          return state is ShowRecentDocumentsState
              ? _showRecentlyOpenedItems(
                  context,
                  state.recentDocuments,
                  state.hasMore,
                )
              : _showNoRecentDocumentsPlaceholder(context);
        },
      ),
    );
  }

  Widget _showRecentlyOpenedItems(
    BuildContext context,
    List<RecentDocumentInfo> recentDocs,
    bool hasMore,
  ) {
    return Expanded(
      child: Scrollbar(
        child: GridView.count(
          crossAxisCount: 3,
          children: [
            ...recentDocs
                .map(
                  (e) => StartupScreenButtonContainer(
                    onPressed: () {
                      Modular.to
                          .pushNamed<Document>('/document/open',
                              arguments: e.path)
                          .then((resultDocument) {
                        if (resultDocument != null) {
                          return _runWorksheetEditorScreen(resultDocument);
                        }
                      });
                    },
                    child: RecentDocumentTile(
                      name: e.name,
                      updateDate: e.updateDate,
                    ),
                  ),
                )
                .toList(),
            if (hasMore)
              StartupScreenButtonContainer(
                onPressed: () => context
                    .read<RecentDocumentsBloc>()
                    .add(FetchRecentDocumentsEvent()),
                child: ShowMoreTile(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _showNoRecentDocumentsPlaceholder(BuildContext context) => Expanded(
        child: Center(
          child: Text(
            'Здесь появятся последние открытые документы',
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(color: Theme.of(context).hintColor),
          ),
        ),
      );
}
