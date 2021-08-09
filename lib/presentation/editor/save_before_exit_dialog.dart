import 'package:flutter/material.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:kres_requests2/presentation/bloc/editor/document_master_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SaveBeforeExitDialog extends StatelessWidget {
  final DocumentManager documentManager;

  const SaveBeforeExitDialog({
    Key? key,
    required this.documentManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Несохраненные изменения'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Следующие документы имеют несохраненные изменения'),
          const SizedBox(height: 12.0),
          SizedBox(
            height: 260.0,
            width: 400.0,
            child: _buildContent(context),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.all(16.0),
      actions: [
        TextButton(
          child: const Text('Не сохранять изменения'),
          onPressed: () {
            context
                .read<DocumentMasterBloc>()
                .add(const DiscardChangesEvent(EventBehaviour.pop));
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(width: 8.0),
        ElevatedButton(
          child: const Text('Отмена'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8.0),
        ElevatedButton(
          child: const Text('Сохранить'),
          onPressed: () {
            context
                .read<DocumentMasterBloc>()
                .add(const SaveAllEvent(EventBehaviour.pop));
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final unsavedDocs = documentManager.unsaved;
    return ListView(
      children: unsavedDocs
          .map((e) => e.suggestedName)
          .map(
            (e) => ListTile(
              leading: const Icon(Icons.save_outlined),
              title: Text(e),
            ),
          )
          .toList(growable: false),
    );
  }
}
