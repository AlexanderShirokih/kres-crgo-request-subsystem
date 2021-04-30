import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/screens/common.dart';

/// Page used to show document import wizard
/// Requires [ImporterBloc] to be injected
abstract class ImporterScreen extends StatelessWidget {
  /// Page title
  final String title;

  const ImporterScreen({
    required this.title,
  });

  /// Builder for titling screen
  Widget buildIdleView(BuildContext context);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Builder(
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
                return buildIdleView(context);
              }
            },
            listener: (context, state) {
              if (state is ImporterDoneState) {
                Navigator.pop(context, state.document);
              } else if (state is ImporterModuleMissingState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 6),
                    content: Text('Ошибка: Модуль экспорта файлов отсутcтвует'),
                  ),
                );
              }
            },
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
