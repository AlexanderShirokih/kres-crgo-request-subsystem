import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:meta/meta.dart';

part 'recent_docs_event.dart';
part 'recent_docs_state.dart';

/// BLoC that handles actions for showing recent documents
class RecentDocumentsBloc extends Bloc<RecentDocsEvent, RecentDocsState> {
  final StreamedRepositoryController<RecentDocumentInfo> _recentDocsController;

  StreamSubscription? _recentDocsSubscription;

  /// Creates new [RecentDocumentsBloc]
  RecentDocumentsBloc(
    this._recentDocsController,
  ) : super(const NoRecentDocumentsState()) {
    add(const FetchRecentDocumentsEvent());

    _recentDocsSubscription = _recentDocsController.stream.listen((recentDocs) {
      add(_UpdateRecentDocs(recentDocs));
    });
  }

  @override
  Stream<RecentDocsState> mapEventToState(RecentDocsEvent event) async* {
    if (event is FetchRecentDocumentsEvent) {
      yield* _fetchRecentDocuments();
    } else if (event is _UpdateRecentDocs) {
      yield* _handleRecentDocsList(event.recentDocuments);
    }
  }

  Stream<RecentDocsState> _fetchRecentDocuments() async* {
    final recentDocs = await _recentDocsController.getAll();
    yield* _handleRecentDocsList(recentDocs);
  }

  Stream<RecentDocsState> _handleRecentDocsList(
      List<RecentDocumentInfo> recentDocs) async* {
    var currentLimit = 5;

    if (state is ShowRecentDocumentsState) {
      final recentState = (state as ShowRecentDocumentsState);
      currentLimit += recentState.recentDocuments.length;
    }

    final alive = await _filterAlive(recentDocs).toList();

    if (alive.isEmpty) {
      yield const NoRecentDocumentsState();
      return;
    }

    yield ShowRecentDocumentsState(
      alive.take(currentLimit).toList(),
      alive.length > currentLimit,
    );
  }

  Stream<RecentDocumentInfo> _filterAlive(
      List<RecentDocumentInfo> list) async* {
    for (final doc in list) {
      if (await doc.path.exists()) {
        yield doc;
      } else {
        _recentDocsController.delete(doc);
      }
    }
    await _recentDocsController.commit();
  }

  @override
  Future<void> close() {
    _recentDocsSubscription?.cancel();
    return super.close();
  }
}
