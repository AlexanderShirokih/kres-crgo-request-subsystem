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
  final Widget Function(Document) mainWidgetBuilder;

  const BaseImporterScreen({
    @required this.title,
    @required this.importer,
    @required this.targetDocument,
    @required this.mainWidgetBuilder,
  })  : assert(title != null),
        assert(importer != null),
        assert(targetDocument != null),
        assert(mainWidgetBuilder != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocProvider.value(
        value: ImporterBloc(importer),
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
              } else
                return mainWidgetBuilder(targetDocument);
            },
            listener: (_, state) {
              if (state is WorksheetReadyState) {
                Navigator.pop(context, targetDocument);
              }
            },
          ),
        ),
      ),
    );
  }
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
