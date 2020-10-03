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
          builder: (ctx) => BlocConsumer(
            cubit: ctx.bloc<ImporterBloc>(),
            builder: (_, state) {
              if (state is ImportLoadingState) {
                return LoadingView("Загрузка файла ${state.path}");
              } else if (state is ImportErrorState) {
                return ErrorView(
                  errorDescription: state.error.toString(),
                  stackTrace: state.stackTrace.toString(),
                  onPressed: () =>
                      context.bloc<ImporterBloc>().add(InitialEvent()),
                );
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
