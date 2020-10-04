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
      yield* _doWorksheetImport(event);
    } else if (event is InitialEvent) {
      yield ImporterInitialState();
    }
  }

  Stream<ImporterState> _doWorksheetImport(ImportEvent import) async* {
    Document _copyToTarget(Document source) {
      import.targetDocument
        ..savePath ??= (import.attachPath
            ? File(p.withoutExtension(import.path) + ".json")
            : null)
        ..addWorksheets(source.worksheets);
      return import.targetDocument;
    }

    yield ImportLoadingState(import.path);

    Future<ImporterState> state =
        _worksheetImporter.importDocument(import.path).then(
      (importedDocument) {
        if (importedDocument == null) return ImportEmptyState();

        final newTarget = import.targetDocument == null
            ? (importedDocument..savePath = File(import.path))
            : _copyToTarget(importedDocument);

        return WorksheetReadyState(newTarget);
      },
    );

    yield await state.catchError((e, s) => ImportErrorState(e, s));
  }
}
