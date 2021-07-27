import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/models/worksheet.dart';
import 'package:kres_requests2/domain/service/document_service.dart';
import 'package:kres_requests2/presentation/bloc.dart';
import 'package:kres_requests2/presentation/bloc/editor/doc_view/worksheet_creation_mode.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'document_event.dart';

/// Data class that wraps info about current document state
class DocumentInfo extends Equatable {
  /// Currently active worksheet
  final Worksheet active;

  /// All available worksheets
  final List<Worksheet> all;

  /// Returns index of active worksheet in [all] list
  int get activePosition => all.indexWhere((ws) => ws == active);

  const DocumentInfo(this.active, this.all);

  @override
  List<Object?> get props => [active, all];
}

/// BLoC to manage document state
class DocumentBloc extends Bloc<DocumentEvent, BaseState> {
  /// [DocumentService] to manage document properties
  final DocumentService _service;

  /// Navigator for navigating
  final IModularNavigator _navigator;

  /// Subscription to document updates
  late StreamSubscription<DocumentInfo> _subscription;

  DocumentBloc(this._service, this._navigator) : super(const InitialState()) {
    final worksheets = _service.document.worksheets;

    _subscription = Rx.combineLatest2<List<Worksheet>, Worksheet, DocumentInfo>(
      worksheets.stream,
      worksheets.activeStream,
      (all, active) => DocumentInfo(active, all),
    ).listen((info) => add(_UpdateDocumentInfo(info)));
    // _service.document.
  }

  @override
  Stream<BaseState> mapEventToState(DocumentEvent event) async* {
    if (event is _UpdateDocumentInfo) {
      yield DataState<DocumentInfo>(event.info);
    } else if (event is WorksheetActionEvent) {
      yield* _handleWorksheetAction(event.targetWorksheet, event.action);
    } else if (event is AddNewWorksheetEvent) {
      yield* _createNewWorksheet(event.mode);
    }
  }

  Stream<BaseState> _handleWorksheetAction(
      Worksheet targetWorksheet, WorksheetAction action) async* {
    switch (action) {
      case WorksheetAction.remove:
        _service.removeWorksheet(targetWorksheet);
        break;
      case WorksheetAction.makeActive:
        _service.makeActive(targetWorksheet);
        break;
    }
  }

  Stream<BaseState> _createNewWorksheet(WorksheetCreationMode mode) async* {
    switch (mode) {
      case WorksheetCreationMode.import:
        _navigator.navigate('/document/import/requests');
        return;
      case WorksheetCreationMode.importCounters:
        _navigator.navigate('/document/import/counters');
        return;
      case WorksheetCreationMode.importNative:
        _navigator.navigate('/document/open?pickPages=true');
        return;
      case WorksheetCreationMode.empty:
        _service.addEmptyWorksheet();
    }
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await super.close();
  }
}
