import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/service/dialog_service.dart';
import 'package:kres_requests2/domain/service/directory_chooser.dart';
import 'package:kres_requests2/domain/service/import_file_chooser.dart';
import 'package:kres_requests2/domain/usecases/log/log_saver.dart';
import 'package:kres_requests2/domain/usecases/storage/database_path.dart';
import 'package:kres_requests2/domain/usecases/storage/import_database_data.dart';
import 'package:kres_requests2/domain/usecases/storage/make_dump_file.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'db_utils_event.dart';

part 'db_utils_data.dart';

class DatabaseUtilsBloc extends Bloc<DatabaseUtilsEvent, BaseState> {
  final GetDatabasePath getDatabasePath;
  final UpdateDatabasePath updateDatabasePath;
  final DirectoryChooser dbPathChooser;
  final DirectoryChooser dumpPathChooser;
  final ImportFileChooser dumpFileChooser;
  final MakeDatabaseDump makeDatabaseDump;
  final DatabaseImporter importDatabase;
  final DialogService dialogService;
  final ErrorLogger errorLogger;

  DatabaseUtilsBloc({
    required this.getDatabasePath,
    required this.updateDatabasePath,
    required this.importDatabase,
    required this.dbPathChooser,
    required this.dumpPathChooser,
    required this.dumpFileChooser,
    required this.makeDatabaseDump,
    required this.dialogService,
    required this.errorLogger,
  }) : super(const InitialState()) {
    add(_FetchCurrentInfo());
  }

  @override
  Stream<BaseState> mapEventToState(DatabaseUtilsEvent event) async* {
    if (event is _FetchCurrentInfo) {
      yield* _fetchData();
    } else if (event is UpdateDatabaseLocation) {
      yield* _updateDatabaseLocation();
    } else if (event is ExportFromDatabase) {
      yield* _makeDatabaseDump();
    } else if (event is ImportIntoDatabase) {
      yield* _importIntoDatabase();
    }
  }

  Stream<BaseState> _fetchData() async* {
    final currentDatabasePath = await getDatabasePath();

    yield DataState(
      DatabaseUtilsData(
        currentDatabasePath: currentDatabasePath,
      ),
    );
  }

  Stream<BaseState> _updateDatabaseLocation() async* {
    final chosenDirectory = await dbPathChooser.chooseDirectory();

    if (chosenDirectory != null) {
      // Update the database path
      await updateDatabasePath(chosenDirectory);

      yield* _fetchData();
    }
  }

  Stream<BaseState> _makeDatabaseDump() async* {
    final dumpDirectory = await dumpPathChooser.chooseDirectory();

    if (dumpDirectory != null) {
      try {
        await makeDatabaseDump(dumpDirectory);
        dialogService.showInfoMessage('Экспорт завершен!');
      } catch (e, s) {
        errorLogger(e, s);
        dialogService.showErrorMessage('Не удалось завершить экспорт!');
      }
      yield* _fetchData();
    }
  }

  Stream<BaseState> _importIntoDatabase() async* {
    final dumpFile = await dumpFileChooser.pickFile();

    if (dumpFile != null) {
      try {
        await importDatabase(dumpFile);
        dialogService.showInfoMessage('Импорт завершен!');
      } catch (e, s) {
        errorLogger(e, s);
        dialogService.showErrorMessage('Не удалось выполнить импорт!');
      }
    }
  }
}
