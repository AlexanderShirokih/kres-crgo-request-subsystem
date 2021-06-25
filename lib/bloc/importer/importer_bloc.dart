import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:kres_requests2/domain/service/file_picker_service.dart';
import 'package:kres_requests2/domain/service/import/document_import_service.dart';
import 'package:kres_requests2/screens/bloc.dart';

part 'importer_event.dart';

part 'importer_state.dart';

/// BLoС that controls importing document to a new document
/// from external sources
class ImporterBloc extends Bloc<ImporterEvent, BaseState> {
  /// Service for handling import results
  final DocumentImporter importService;

  /// Current document manager instance
  final DocumentManager documentManager;

  /// Service for picking a file
  final FilePicker pickerService;

  /// Navigator service
  final IModularNavigator navigator;

  ImporterBloc({
    required this.documentManager,
    required this.importService,
    required this.pickerService,
    required this.navigator,
  }) : super(InitialState());

  @override
  Stream<BaseState> mapEventToState(ImporterEvent event) async* {
    if (event is ImportEvent) {
      void navigateToEditor() {
        navigator.navigate('/document/edit');
      }

      yield PickingFileState();

      final resultPath = await pickerService.chooseSourcePath(event.filePath);

      if (resultPath == null) {
        navigateToEditor();
        return;
      }

      yield LoadingState();

      try {
        await importService.importDocument(resultPath, documentManager);
        navigateToEditor();
      } on ImporterModuleMissingException {
        yield ImporterModuleMissingState();
      } catch (e, s) {
        yield ErrorState(e.toString(), s);
      }
    }
  }
}
