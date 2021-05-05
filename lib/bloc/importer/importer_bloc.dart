import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/exchange/document_import_service.dart';
import 'package:kres_requests2/domain/exchange/file_chooser.dart';
import 'package:kres_requests2/domain/exchange/megabilling_import_service.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

part 'importer_event.dart';

part 'importer_state.dart';

/// BLoС that controls importing worksheets to the existing or a new document
/// from external sources
class ImporterBloc extends Bloc<ImporterEvent, ImporterState> {
  /// Repository for importing data
  final DocumentImporterService importerService;

  /// Target document where should consists import results
  final Document? targetDocument;

  /// Function for picking files from the storage
  final FileChooser fileChooser;

  ImporterBloc({
    this.targetDocument,
    required this.importerService,
    required this.fileChooser,
    File? filePath,
    bool startWithPicker = false,
  }) : super(ImporterInitialState()) {
    if (startWithPicker || filePath != null) {
      add(ImportEvent(filePath: filePath));
    }
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    add(_ImportErrorEvent(error, stackTrace));
    super.onError(error, stackTrace);
  }

  @override
  Stream<ImporterState> mapEventToState(ImporterEvent event) async* {
    if (event is ImportEvent) {
      yield* _doWorksheetImport(event);
    } else if (event is _ImportErrorEvent) {
      yield ImportErrorState(event.error.toString(), event.stackTrace);
    }
  }

  Future<String?> _chooseSourcePath(ImportEvent import) async {
    if (import.filePath != null && await import.filePath!.exists()) {
      return import.filePath!.absolute.path;
    }
    return await fileChooser.pickFile();
  }

  Stream<ImporterState> _doWorksheetImport(ImportEvent import) async* {
    final filePath = await _chooseSourcePath(import);

    if (filePath == null) {
      yield ImporterDoneState(importResult: ImportResult.importCancelled);
      return;
    }

    Future<Document> _copyToTarget(Document source) async {
      final target = targetDocument!;

      final currentSavePath = target.currentSavePath;
      if (currentSavePath == null) {
        target.setSavePath(File(p.withoutExtension(filePath) + ".json"));
      }

      return target..addWorksheets(source.currentWorksheets);
    }

    yield ImporterLoadingState(filePath);

    try {
      final document = await importerService.importDocument(filePath);

      if (document == null) {
        yield ImporterDoneState(importResult: ImportResult.importCancelled);
        return;
      }

      final isEmpty = document.currentIsEmpty;
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
    } catch (e, s) {
      yield ImportErrorState(e.toString(), s);
    }
  }
}
