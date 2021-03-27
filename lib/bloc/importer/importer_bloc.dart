import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

part 'importer_event.dart';
part 'importer_state.dart';

/// BLoc that controls importing worksheet to the existing or a new document
/// from external sources
class ImporterBloc extends Bloc<ImporterEvent, ImporterState> {
  /// Repository for importing data
  final WorksheetImporterRepository importerRepository;

  /// Target document where should consists import results
  final Document? targetDocument;

  /// Function for picking files from the storage
  final Future<String?> Function() fileChooser;

  ImporterBloc({
    this.targetDocument,
    required this.importerRepository,
    required this.fileChooser,
    required bool pickFileOnStart,
  }) : super(ImporterInitialState()) {
    if (pickFileOnStart) add(ImportEvent());
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    add(ImportErrorEvent(error, stackTrace));
    super.onError(error, stackTrace);
  }

  @override
  Stream<ImporterState> mapEventToState(ImporterEvent event) async* {
    if (event is InitialEvent) {
      yield ImporterInitialState();
    } else if (event is ImportEvent) {
      yield* _doWorksheetImport(event);
    } else if (event is ImportErrorEvent) {
      yield ImportErrorState(event.error.toString(), event.stackTrace);
    }
  }

  Stream<ImporterState> _doWorksheetImport(ImportEvent import) async* {
    final file = await fileChooser();

    if (file == null) {
      yield ImporterDoneState(importResult: ImportResult.importCancelled);
      return;
    }

    Future<Document> _copyToTarget(Document source) async {
      final target = targetDocument!;

      if (import.attachPath) {
        target.setSavePath(File(p.withoutExtension(file) + ".json"));
      }

      return target..addWorksheets(await source.worksheets.first);
    }

    yield ImporterLoadingState(file);
    try {
      final document =
          await importerRepository.importDocument(file);

      if (document == null) {
        yield ImporterDoneState(importResult: ImportResult.importCancelled);
        return;
      }

      final isEmpty = await document.isEmpty.first;
      if (isEmpty) {
        yield ImporterDoneState(importResult: ImportResult.documentEmpty);
        return;
      }

      final newTarget =
          targetDocument == null ? document : await _copyToTarget(document);

      yield ImporterDoneState(
        document: newTarget,
        importResult: ImportResult.done,
      );
    } on ImporterProcessorMissingException {
      yield ImporterModuleMissingState();
    } on ErrorWrapper catch (e) {
      yield ImportErrorState(e.error.toString(), e.stackTrace);
    } catch (e, s) {
      yield ImportErrorState(e.toString(), s);
    }
  }
}
