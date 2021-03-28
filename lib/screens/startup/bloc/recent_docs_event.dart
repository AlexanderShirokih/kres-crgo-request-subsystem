part of 'recent_docs_bloc.dart';

/// Base event class for [RecentDocumentsBloc]
@sealed
abstract class RecentDocsEvent extends Equatable {
  const RecentDocsEvent._();
}

/// Used to fetch recent document from repository. Next event calls will cause
/// fetching more items.
class FetchRecentDocumentsEvent extends RecentDocsEvent {
  const FetchRecentDocumentsEvent() : super._();

  @override
  List<Object?> get props => [];
}

/// Used internally to deliver updates on recent document list
class _UpdateRecentDocs extends RecentDocsEvent {
  final List<RecentDocumentInfo> recentDocuments;

  const _UpdateRecentDocs(this.recentDocuments) : super._();

  @override
  List<Object?> get props => [recentDocuments];
}
