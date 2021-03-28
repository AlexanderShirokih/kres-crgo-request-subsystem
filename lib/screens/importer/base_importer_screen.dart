import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';
import 'package:kres_requests2/screens/common.dart';

/// Common screen for all importer types
abstract class BaseImporterScreen extends StatelessWidget {
  /// Page title
  final String title;

  /// Repository for importing objects
  final WorksheetImporterRepository importerRepository;

  /// Target document to be inflated with importer results.
  /// If not present then new document will be created
  final Document? targetDocument;

  /// Builder for titling screen
  final WidgetBuilder mainWidgetBuilder;

  /// Path for opening. If present document will be opened from this path.
  /// Otherwise file chooser will be opened.
  final File? openPath;

  const BaseImporterScreen({
    required this.title,
    required this.importerRepository,
    required this.targetDocument,
    required this.mainWidgetBuilder,
    this.openPath,
  });

  /// Creates proper file chooser
  Future<String?> showOpenDialog(BuildContext context);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: BlocProvider(
          create: (_) => ImporterBloc(
            targetDocument: targetDocument,
            filePath: openPath,
            importerRepository: importerRepository,
            fileChooser: () => showOpenDialog(context),
          ),
          child: Builder(
            builder: (ctx) => BlocConsumer<ImporterBloc, ImporterState>(
              bloc: ctx.read<ImporterBloc>(),
              builder: (_, state) {
                if (state is ImporterLoadingState) {
                  return LoadingView("Загрузка файла ${state.path}");
                } else if (state is ImportErrorState) {
                  return ErrorView(
                    errorDescription: state.error,
                    stackTrace: state.stackTrace,
                  );
                } else if (state is ImporterDoneState &&
                    state.importResult == ImportResult.documentEmpty) {
                  return _EmptyStateView();
                } else {
                  return mainWidgetBuilder(context);
                }
              },
              listener: (context, state) {
                if (state is ImporterDoneState) {
                  Navigator.pop(context, state.document);
                } else if (state is ImporterModuleMissingState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: Duration(seconds: 6),
                      content:
                          Text('Ошибка: Модуль экспорта файлов отсутcтвует'),
                    ),
                  );
                }
              },
            ),
          ),
        ),
      );
}

class _EmptyStateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Полученный документ оказался пуст',
            style: Theme.of(context).textTheme.headline4,
          ),
          const SizedBox(height: 28.0),
          ElevatedButton(
            child: Text('НАЗАД'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
