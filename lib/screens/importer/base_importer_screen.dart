import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/common/worksheet_importer.dart';
import 'package:kres_requests2/data/document.dart';
import 'package:kres_requests2/screens/common.dart';

abstract class BaseImporterScreen extends StatelessWidget {
  final String title;
  final WorksheetImporter importer;
  final Document targetDocument;
  final WidgetBuilder mainWidgetBuilder;
  final bool forceFileSelection;

  const BaseImporterScreen({
    @required this.title,
    @required this.importer,
    @required this.targetDocument,
    @required this.mainWidgetBuilder,
    @required this.forceFileSelection,
  })  : assert(title != null),
        assert(importer != null),
        assert(mainWidgetBuilder != null);

  Future<String> showOpenDialog(BuildContext context);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: BlocProvider.value(
          value: ImporterBloc(
            importer: importer,
            fileChooser: () => showOpenDialog(context),
            targetDocument: targetDocument,
            forceFileChooser: forceFileSelection,
          ),
          child: Builder(
            builder: (ctx) => BlocConsumer<ImporterBloc, ImporterState>(
              cubit: ctx.bloc<ImporterBloc>(),
              builder: (_, state) {
                if (state is ImportLoadingState) {
                  return LoadingView("Загрузка файла ${state.path}");
                } else if (state is ImportErrorState) {
                  return ErrorView(
                    errorDescription: state.error?.toString(),
                    stackTrace: state.stackTrace?.toString(),
                  );
                } else if (state is ImportEmptyState) {
                  return _EmptyStateView();
                } else {
                  return mainWidgetBuilder(context);
                }
              },
              listener: (context, state) {
                if (state is WorksheetReadyState) {
                  Navigator.pop(context, state.document);
                } else if (state is ImporterProccessMissingState) {
                  Scaffold.of(context).showSnackBar(
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
            'Полученный список оказался пуст',
            style: Theme.of(context).textTheme.headline4,
          ),
          const SizedBox(height: 28.0),
          RaisedButton(
            padding: EdgeInsets.all(24.0),
            color: Theme.of(context).primaryColor,
            textColor: Theme.of(context).primaryTextTheme.bodyText2.color,
            child: Text('НАЗАД'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
