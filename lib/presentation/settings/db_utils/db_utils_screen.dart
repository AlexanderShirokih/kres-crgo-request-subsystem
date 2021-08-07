import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/service/database_exporter.dart';
import 'package:kres_requests2/domain/service/dialog_service.dart';
import 'package:kres_requests2/domain/service/directory_chooser.dart';
import 'package:kres_requests2/domain/service/import_file_chooser.dart';
import 'package:kres_requests2/domain/usecases/log/log_saver.dart';
import 'package:kres_requests2/domain/usecases/storage/database_path.dart';
import 'package:kres_requests2/domain/usecases/storage/get_current_directory.dart';
import 'package:kres_requests2/domain/usecases/storage/import_database_data.dart';
import 'package:kres_requests2/domain/usecases/storage/make_dump_file.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/bloc/settings/db_utils/db_utils_bloc.dart';
import 'package:kres_requests2/presentation/common/dialog_service.dart';

import 'import_warning_dialog.dart';

/// Screen that allows to manage database location, export or import data in it
class DatabaseUtilsScreen extends StatelessWidget {
  const DatabaseUtilsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogManager(
      dialogService: Modular.get(),
      child: BlocProvider(
        create: (_) => DatabaseUtilsBloc(
          errorLogger: ErrorLogger(),
          dialogService: Modular.get<DialogService>(),
          getDatabasePath: Modular.get<GetDatabasePath>(),
          updateDatabasePath: Modular.get<UpdateDatabasePath>(),
          importDatabase: Modular.get<DatabaseImporter>(),
          dbPathChooser: DirectoryChooserImpl(Modular.get<GetDatabasePath>()),
          dumpPathChooser: DirectoryChooserImpl(GetCurrentDirectory()),
          makeDatabaseDump: MakeDatabaseDump(Modular.get<DatabaseExporter>()),
          dumpFileChooser: FileChooserImpl(
            label: 'Сценарий SQL',
            extensions: ['sql'],
            getWorkingDirectory: GetCurrentDirectory(),
          ),
        ),
        child: BlocBuilder<DatabaseUtilsBloc, BaseState>(
          builder: (context, state) {
            if (state is DataState<DatabaseUtilsData>) {
              return _buildLayout(context, state.data);
            } else if (state is LoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return Text(
                'Что-то пошло не так',
                style: Theme.of(context).textTheme.headline4,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, DatabaseUtilsData data) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Путь к базе данных',
          style: theme.textTheme.headline5,
        ),
        const SizedBox(height: 12.0),
        SelectableText(
          data.currentDatabasePath,
          style: const TextStyle(color: Colors.blue),
        ),
        TextButton(
          child: const Text('Изменить путь'),
          onPressed: () {
            context.read<DatabaseUtilsBloc>().add(UpdateDatabaseLocation());
          },
        ),
        const SizedBox(height: 12.0),
        const Text(
            'Чтобы изменения вступили в силу необходим перезапуск программы'),
        const SizedBox(height: 12.0),
        Text(
          'Указав неверный путь вы можете потерять доступ к данным!',
          style: theme.textTheme.bodyText2!.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.errorColor,
          ),
        ),
        const Divider(),
        Text(
          'Импорт данных',
          style: theme.textTheme.headline5,
        ),
        const SizedBox(height: 8.0),
        Text(
          'Импортировать данные в базу данных из существующего SQLite файла',
          style: theme.textTheme.caption,
        ),
        const SizedBox(height: 8.0),
        Text(
          'Имортирование чего попало может привести к неприятностям',
          style: theme.textTheme.bodyText2!.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.errorColor,
          ),
        ),
        TextButton(
          child: const Text('Импортировать'),
          onPressed: () {
            showDialog<bool>(
                    context: context,
                    builder: (_) => const ImportWarningDialog())
                .then((bool? isAccepted) {
              if (isAccepted != null && isAccepted) {
                context.read<DatabaseUtilsBloc>().add(ImportIntoDatabase());
              }
            });
          },
        ),
        const Divider(),
        Text(
          'Экспорт данных',
          style: theme.textTheme.headline5,
        ),
        const SizedBox(height: 8.0),
        Text(
          'Создать дамп данных из текущей базы данных',
          style: theme.textTheme.caption,
        ),
        const SizedBox(height: 8.0),
        TextButton(
          child: const Text('Экспортировать'),
          onPressed: () {
            context.read<DatabaseUtilsBloc>().add(ExportFromDatabase());
          },
        ),
      ],
    );
  }
}
