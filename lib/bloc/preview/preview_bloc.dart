import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:meta/meta.dart';

part 'preview_events.dart';
part 'preview_states.dart';

/// BLoC for preparing document worksheets for printing or
/// exporting to external formats
class PreviewBloc extends Bloc<PreviewEvent, PreviewState> {
  /// Currently opened document
  final Document document;

  PreviewBloc(this.document) : super(PreviewInitialState()) {
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
    final worksheets = document.worksheets.list;

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
      document,
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
