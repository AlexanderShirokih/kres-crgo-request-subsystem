import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/common/worksheet_importer.dart';
import 'package:kres_requests2/data/document.dart';

part 'importer_event.dart';

part 'importer_state.dart';

class ImporterBloc extends Bloc<ImporterEvent, ImporterState> {
  final WorksheetImporter _worksheetImporter;

  ImporterBloc(this._worksheetImporter) : super(ImporterInitialState());

  @override
  Stream<ImporterState> mapEventToState(ImporterEvent event) async* {
    if (event is ImportEvent) {
      yield* _doWorksheetImport(event.path, event.targetDocument);
    } else if (event is InitialEvent) {
      yield ImporterInitialState();
    }
  }

  Stream<ImporterState> _doWorksheetImport(
      String path, Document targetDocument) async* {
    yield ImportLoadingState(path);

    Future<ImporterState> state = _worksheetImporter.importWorksheet(path).then(
      (importedWorksheet) {
        if (importedWorksheet == null) return ImportEmptyState();
        targetDocument
          ..savePath ??= File(p.withoutExtension(path) + ".json")
          ..addWorksheet(importedWorksheet);
        return WorksheetReadyState();
      },
    );

    yield await state.catchError((e, s) => ImportErrorState(e, s));
  }
}
