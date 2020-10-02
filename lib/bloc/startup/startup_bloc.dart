import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/repo/worksheet_repository.dart';
import 'package:kres_requests2/data/document.dart';
import 'package:path/path.dart' as p;

part 'startup_event.dart';

part 'startup_state.dart';

class StartupBloc extends Bloc<StartupEvent, StartupState> {
  final WorksheetRepository _worksheetRepository;

  StartupBloc(this._worksheetRepository) : super(StartupInitial());

  @override
  Stream<StartupState> mapEventToState(StartupEvent event) async* {
    if (event is StartupImportEvent) {
      yield* _doWorksheetImport(event.path);
    } else if (event is StartupInitialEvent) {
      yield StartupInitial();
    }
  }

  Stream<StartupState> _doWorksheetImport(String path) async* {
    yield StartupLoadingState(path);

    yield await _worksheetRepository
        .importWorksheet(File(path))
        .then(
          (importedWorksheet) => StartupShowDocumentState(
            Document(
              savePath: File(p.withoutExtension(path) + ".json"),
              worksheets: [importedWorksheet],
            ),
          ),
        )
        .catchError((e, s) => StartupErrorState(e, s));
  }
}
