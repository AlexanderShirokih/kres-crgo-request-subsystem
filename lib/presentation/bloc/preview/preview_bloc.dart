import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:meta/meta.dart';

part 'preview_events.dart';

part 'preview_states.dart';

/// BLoC for preparing document worksheets for printing or
/// exporting to external formats
class PreviewBloc extends Bloc<PreviewEvent, PreviewState> {
  /// Document manager instance
  final DocumentManager manager;

  PreviewBloc(this.manager) : super(PreviewInitialState()) {
    add(_CheckDocumentEvent());
  }

  @override
  Stream<PreviewState> mapEventToState(PreviewEvent event) async* {
    if (event is _CheckDocumentEvent) {
      yield* _checkDocumentInfo();
    } else if (event is UpdateSelectedEvent) {
      yield* _updateSelected(event.selectedWorksheets);
    }
  }

  Stream<PreviewState> _checkDocumentInfo() async* {
    final selected = manager.selected;

    if (selected == null) {
      yield EmptyDocumentState();
      return;
    }

    final worksheets = selected.worksheets.list;

    final nonEmptyWorksheets = worksheets
        .where((worksheet) => !worksheet.isEmpty)
        .toList(growable: false);

    if (nonEmptyWorksheets.isEmpty) {
      yield EmptyDocumentState();
      return;
    }

    final validWorksheets = nonEmptyWorksheets
        .where((worksheet) => !worksheet.hasErrors())
        .toList();

    yield ShowDocumentState(
      selected,
      allWorksheet: nonEmptyWorksheets,
      selectedWorksheets: validWorksheets,
    );
  }

  Stream<PreviewState> _updateSelected(
    List<Worksheet> selectedWorksheets,
  ) async* {
    final currentState = state;
    if (currentState is! ShowDocumentState) {
      return;
    }

    yield currentState.copy(selectedWorksheets: selectedWorksheets);
  }
}
