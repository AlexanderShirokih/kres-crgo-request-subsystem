import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';

part 'importer_event.dart';
part 'importer_state.dart';

class ImporterBloc extends Bloc<ImporterEvent, ImporterState> {
  final WorksheetImporterRepository importerRepository;
  final Document? targetDocument;
  final Future<String?> Function()? fileChooser;
  final dynamic importerParams;

  ImporterBloc({
    this.targetDocument,
    required this.importerRepository,
    required this.fileChooser,
    required this.importerParams,
    required bool forceFileChooser,
  }) : super(ImporterInitialState()) {
    if (forceFileChooser) add(ImportEvent());
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    add(ImportErrorEvent(error, stackTrace));
    super.onError(error, stackTrace);
  }

  @override
  Stream<ImporterState> mapEventToState(ImporterEvent event) async* {
    if (event is ImportEvent) {
      yield* _doWorksheetImport(event);
    } else if (event is InitialEvent) {
      yield ImporterInitialState();
    } else if (event is ImportErrorEvent) {
      yield ImportErrorState(event.error.toString(), event.stackTrace);
    }
  }

  Stream<ImporterState> _doWorksheetImport(ImportEvent import) async* {
    if (fileChooser == null) {
      throw 'No file chooser passed!';
    }
    final file = await fileChooser!();
    if (file == null) {
      yield WorksheetReadyState(null);
      return;
    }

    Document _copyToTarget(Document source) {
      // TODO: Migrate
      // targetDocument!
      //   ..savePath ??= (import.attachPath
      //       ? File(p.withoutExtension(file) + ".json")
      //       : null)
      //   ..addWorksheets(source.worksheets);
      return targetDocument!;
    }

    yield ImportLoadingState(file);

    Future<ImporterState> state =
        importerRepository.importDocument(file, importerParams).then(
      (OptionalData<Document>? importedDocument) {
        if (importedDocument == null) return ImportEmptyState();

        if (importedDocument.hasError()) {
          throw importedDocument.error!;
        }

        final document = importedDocument.data;
        final newTarget =
            targetDocument == null ? document : _copyToTarget(document!);

        return WorksheetReadyState(newTarget);
      },
    );

    yield await state.catchError((e, s) {
      if (e is ImporterProcessorMissingException) {
        return ImporterProccessMissingState();
      } else if (e is ErrorWrapper) {
        return ImportErrorState(e.error.toString(), e.stackTrace);
      } else {
        return ImportErrorState(e.toString(), s);
      }
    });
  }
}
