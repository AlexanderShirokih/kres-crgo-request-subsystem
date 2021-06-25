import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/editor/document_master_bloc.dart';

/// Represents document tabs bar. This bar shows tabs to switch between
/// opened documents.
/// There is an add button to create an empty document.
/// Requires [DocumentMasterBloc] to be injected.
class DocumentTabsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _createTabs()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: IconButton(
            onPressed: () =>
                context.read<DocumentMasterBloc>().add(CreatePage()),
            icon: Icon(Icons.add),
            color: Theme.of(context).colorScheme.onPrimary,
            tooltip: 'Новый документ',
          ),
        ),
      ],
    );
  }

  Widget _createTabs() => BlocBuilder<DocumentMasterBloc, DocumentMasterState>(
        builder: (context, state) {
          if (state is! ShowDocumentsState) {
            return Container();
          }

          final all = state.all;

          return TabBar(
            onTap: (tab) => context
                .read<DocumentMasterBloc>()
                .add(SetSelectedPage(all[tab].document)),
            tabs: all.map((info) {
              return DocumentTab(
                  title: info.title,
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
            child: IconButton(onPressed: onClose, icon: Icon(Icons.close)),
          ),
        ],
      ),
    );
  }
}
