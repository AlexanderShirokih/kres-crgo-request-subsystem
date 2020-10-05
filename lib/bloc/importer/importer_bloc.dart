import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:path/path.dart' as p;
import 'package:equatable/equatable.dart';

import 'package:kres_requests2/common/worksheet_importer.dart';
import 'package:kres_requests2/data/document.dart';

part 'importer_event.dart';

part 'importer_state.dart';

class ImporterBloc extends Bloc<ImporterEvent, ImporterState> {
  final WorksheetImporter importer;
  final Document targetDocument;
  final Future<String> Function() fileChooser;

  ImporterBloc({
    this.targetDocument,
    @required this.importer,
    @required this.fileChooser,
    @required bool forceFileChooser,
  }) : super(ImporterInitialState()) {
    if (forceFileChooser) add(ImportEvent());
  }

  @override
  Stream<ImporterState> mapEventToState(ImporterEvent event) async* {
    if (event is ImportEvent) {
      yield* _doWorksheetImport(event);
    } else if (event is InitialEvent) {
      yield ImporterInitialState();
    }
  }

  Stream<ImporterState> _doWorksheetImport(ImportEvent import) async* {
    final file = await fileChooser();
    if (file == null) {
      yield WorksheetReadyState(null);
      return;
    }

    Document _copyToTarget(Document source) {
      targetDocument
        ..savePath ??= (import.attachPath
            ? File(p.withoutExtension(file) + ".json")
            : null)
        ..addWorksheets(source.worksheets);
      return targetDocument;
    }

    yield ImportLoadingState(file);

    Future<ImporterState> state = importer.importDocument(file).then(
      (importedDocument) {
        if (importedDocument == null) return ImportEmptyState();

        final newTarget = targetDocument == null
            ? (importedDocument..savePath = File(file))
            : _copyToTarget(importedDocument);

        return WorksheetReadyState(newTarget);
      },
    );

    yield await state.catchError((e, s) {
      return e is ImporterProcessMissingException
          ? ImporterProccessMissingState()
          : ImportErrorState(e, s);
    });
  }
}