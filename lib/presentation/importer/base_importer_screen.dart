import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/presentation/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/common.dart';

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
          builder: (ctx) => BlocConsumer<ImporterBloc, BaseState>(
            bloc: ctx.read<ImporterBloc>(),
            builder: (_, state) {
              if (state is PickingFileState) {
                return LoadingView('Ожидание выбора файла');
              } else if (state is LoadingState) {
                return LoadingView('Загрузка файла');
              } else if (state is ErrorState) {
                return ErrorView(
                  errorDescription: state.error.toString(),
                  stackTrace: state.stackTrace,
                );
              } else {
                return buildIdleView(context);
              }
            },
            listener: (context, state) {
              if (state is ImporterModuleMissingState) {
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
