import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/document_service.dart';
import 'package:kres_requests2/domain/request_set_service.dart';
import 'package:kres_requests2/models/optional_data.dart';
import 'package:kres_requests2/repo/export_repository.dart';
import 'package:kres_requests2/repo/server_exception.dart';

part 'preview_event.dart';

part 'preview_state.dart';

class WorksheetInfo {
  final List<String> errors;
  final bool isChecked;

  WorksheetInfo(this.errors, this.isChecked);
}

class PreviewBloc extends Bloc<PreviewEvent, PreviewState> {
  final ExportRepository _exporterRepository;
  final DocumentService _documentService;

  PreviewBloc(this._documentService, this._exporterRepository)
      : assert(_documentService != null),
        assert(_exporterRepository != null),
        super(PreviewInitial()) {
    add(PreviewFetchStatus());
  }

  @override
  Stream<PreviewState> mapEventToState(PreviewEvent event) async* {
    if (event is PreviewFetchStatus) {
      yield* _validateWorksheets();
    } else if (event is PreviewSelectionChangedEvent) {
      yield* _updateSelection(event);
    }
  }

  Stream<PreviewState> _validateWorksheets() async* {
    yield PreviewValidationState();

    try {
      final worksheets = _documentService
          .getWorksheets()
          .where((element) => !element.isEmpty)
          .toList();
      final result = await _exporterRepository.validateWorksheet(worksheets);

      yield PreviewDataState(
        result.map((key, value) => MapEntry(_documentService.getEditor(key),
            WorksheetInfo(value, value.isEmpty))),
      );
    } on ApiException catch (error, stackTrace) {
      yield PreviewErrorState(
        ErrorWrapper(
          error.toString(),
          stackTrace.toString(),
        ),
      );
    }
  }

  Stream<PreviewState> _updateSelection(
      PreviewSelectionChangedEvent event) async* {
    if (state is PreviewDataState) {
      final dataState = state as PreviewDataState;
      final target = dataState.validatedWorksheets[event.target];
      if (target != null) {
        dataState.validatedWorksheets[event.target] =
            WorksheetInfo(target.errors, event.isSelected);
        yield PreviewInitial();
        yield PreviewDataState(dataState.validatedWorksheets);
      }
    }
  }
}
