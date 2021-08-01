import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/presentation/bloc/editor/document_master_bloc.dart';

/// Represents document tabs bar. This bar shows tabs to switch between
/// opened documents.
/// There is an add button to create an empty document.
/// Requires [DocumentMasterBloc] to be injected.
class DocumentTabsBar extends StatelessWidget {
  const DocumentTabsBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _DocumentTabBarActionButtons(),
        Expanded(child: _createTabs()),
      ],
    );
  }

  Widget _createTabs() => BlocBuilder<DocumentMasterBloc, DocumentMasterState>(
        builder: (context, state) {
          if (state is! ShowDocumentsState) {
            return Container();
          }

          final controller = DefaultTabController.of(context);
          final all = state.all;
          final current = state.pageIndex;

          if (controller!.index != current) {
            // TODO: Called during build!
            controller.index = current;
          }

          return TabBar(
            onTap: (tab) => context
                .read<DocumentMasterBloc>()
                .add(SetSelectedPage(all[tab].document)),
            tabs: all.map((info) {
              return DocumentTab(
                  title: info.title ?? 'Несохраненный документ',
                  isSaved: info.saveState == SaveState.saved,
                  onClose: () => context
                      .read<DocumentMasterBloc>()
                      .add(DeletePage(info.document)));
            }).toList(growable: false),
          );
        },
      );
}

/// Tab representing an opened document
class DocumentTab extends StatelessWidget {
  /// Document title
  final String title;

  /// Callback that called when document is closed
  final VoidCallback onClose;

  /// If `false` then unsaved mark will be shown
  final bool isSaved;

  const DocumentTab({
    Key? key,
    required this.title,
    required this.isSaved,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: Text(title)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child:
                IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
          ),
        ],
      ),
    );
  }
}

class _DropdownActionItem {
  final String title;
  final Widget icon;
  final DocumentMasterEvent event;

  const _DropdownActionItem(this.title, this.icon, this.event);
}

class _DocumentTabBarActionButtons extends StatelessWidget {
  const _DocumentTabBarActionButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const items = [
      _DropdownActionItem(
        'Новый документ',
        Icon(Icons.add),
        CreatePage(),
      ),
      _DropdownActionItem(
        'Открыть другой документ',
        FaIcon(FontAwesomeIcons.fileImport),
        ImportPage(),
      ),
      _DropdownActionItem(
        'Создать документ из файла заявок',
        FaIcon(FontAwesomeIcons.fileExcel),
        ImportMegaBillingRequests(),
      ),
    ];

    final mainItem = items[0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: mainItem.icon,
            tooltip: mainItem.title,
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () =>
                context.read<DocumentMasterBloc>().add(mainItem.event),
          ),
          const SizedBox(width: 4.0),
          IconButton(
            icon: const Icon(Icons.expand_more_outlined),
            tooltip: 'Создать из...',
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: () {
              _showExpandedItems(context, items);
            },
          )
        ],
      ),
    );
  }

  void _showExpandedItems(
      BuildContext context, List<_DropdownActionItem> items) {
    final renderObject = context.findRenderObject();
    if (renderObject != null) {
      final bounds = renderObject.paintBounds;
      final position = RelativeRect.fromSize(
        bounds.shift(bounds.bottomRight).shift(const Offset(0.0, 46.0)),
        const Size(460, 300),
      );

      showMenu(
        context: context,
        position: position,
        items: items
            .map(
              (e) => PopupMenuItem(
                child: ListTile(
                  leading: e.icon,
                  title: Text(e.title),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<DocumentMasterBloc>().add(e.event);
                  },
                ),
              ),
            )
            .toList(),
      );
    }
  }
}
