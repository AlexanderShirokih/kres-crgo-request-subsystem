import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/service/dialog_service.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'document_master_event.dart';

part 'document_master_state.dart';

/// BLoC that manages global state of the [Document]. Can change currently
/// active page, create, update or delete documents or it's pages.
class DocumentMasterBloc extends Bloc<DocumentMasterEvent, DocumentMasterState>
    implements Disposable {
  /// Manager to switch between documents
  final DocumentManager _documentManager;

  /// Navigator for navigating
  final IModularNavigator _navigator;

  /// Dialog service to show an errors
  final DialogService _dialogService;

  StreamSubscription? _subscription;

  /// Creates new [DocumentMasterBloc] instance for [document].
  DocumentMasterBloc(
    this._documentManager,
    this._dialogService,
    this._navigator,
  ) : super(const NoOpenedDocumentsState()) {
    _subscription = Rx.combineLatest2(
      _documentManager.openedDocumentDescriptors,
      _documentManager.selectedStream,
      (List<DocumentDescriptor> list, Document? selected) {
        return SetDocuments(selected, list);
      },
    ).listen((event) {
      add(event);
    });
  }

  @override
  Stream<DocumentMasterState> mapEventToState(
      DocumentMasterEvent event) async* {
    if (event is SetSelectedPage) {
      await _setSelectedPage(event.selected);
    } else if (event is SetDocuments) {
      yield* _setDocuments(event.selected, event.all);
    } else if (event is DeletePage) {
      await _deletePage(event.target);
    } else if (event is CreatePage) {
      await _createNewPage();
    } else if (event is ImportPage) {
      await _importPage();
    } else if (event is ImportMegaBillingRequests) {
      await _importMegaBilling();
    } else if (event is SaveEvent) {
      yield* _saveDocument(event.changePath, event.popAfterSave);
    } else if (event is WorksheetMasterSearchEvent) {
      yield* _toggleSearchMode(event);
    }
  }

  Future<void> _setSelectedPage(Document selected) async {
    final savedState = state;

    if (savedState is ShowDocumentsState) {
      _documentManager.markSelected(selected);
    }
  }

  Future<void> _deletePage(Document target) => _documentManager.close(target);

  Future<void> _createNewPage() => _documentManager.createNew();

  Future<void> _importPage() async {
    _navigator.pushReplacementNamed('/document/open?pickPages=true');
  }

  Future<void> _importMegaBilling() async {
    _navigator.pushReplacementNamed('/document/import/requests');
  }

  Stream<DocumentMasterState> _setDocuments(
    Document? selected,
    List<DocumentDescriptor> all,
  ) async* {
    final allDocumentsInfo = all
        .map(
          (doc) => DocumentInfo(
            doc.hasChanges ? SaveState.unsaved : SaveState.saved,
            doc.document,
          ),
        )
        .toList(growable: false);

    if (selected == null || all.isEmpty) {
      yield const NoOpenedDocumentsState();
    } else {
      yield ShowDocumentsState(selected, allDocumentsInfo);
    }
  }

  Stream<DocumentMasterState> _saveDocument(
    bool changePath,
    bool popAfterSave,
  ) async* {
    final currentState = state;
    if (currentState is! ShowDocumentsState) return;

    final info = currentState.all.toList();
    final currentDocument = currentState.selected;
    final currentInfoIdx =
        info.indexWhere((doc) => doc.document == currentDocument);

    try {
      await for (final saveState
          in _documentManager.save(currentDocument, changePath: changePath)) {
        switch (saveState) {
          case DocumentSavingState.pickingSavePath:
            break;
          case DocumentSavingState.saving:
            info[currentInfoIdx] =
                info[currentInfoIdx].copyWith(saveState: SaveState.saving);
            yield const NoOpenedDocumentsState();
            yield ShowDocumentsState(currentDocument, List.unmodifiable(info));
            break;
          case DocumentSavingState.saved:
            info[currentInfoIdx] =
                info[currentInfoIdx].copyWith(saveState: SaveState.saved);
            yield const NoOpenedDocumentsState();
            yield ShowDocumentsState(currentDocument, List.unmodifiable(info));
            break;
        }
      }

      if (popAfterSave) {
        _navigator.pop();
      }
    } catch (e) {
      _dialogService
          .showErrorMessage('Не удалось сохранить документ! (${e.toString()})');

      info[currentInfoIdx] =
          info[currentInfoIdx].copyWith(saveState: SaveState.unsaved);
      yield ShowDocumentsState(currentDocument, List.unmodifiable(info));
    }
  }

  Stream<DocumentMasterState> _toggleSearchMode(
      WorksheetMasterSearchEvent event) async* {
    throw UnimplementedError();
    // TODO: FIX SEARCH MODE!
    // _service.setSearchFilter(event.searchText ?? '');
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }

  @override
  void dispose() {
    close();
  }
}
