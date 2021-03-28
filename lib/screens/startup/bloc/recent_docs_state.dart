part of 'recent_docs_bloc.dart';

/// Base event class for [RecentDocumentsBloc]
@sealed
abstract class RecentDocsState extends Equatable {
  const RecentDocsState._();
}

/// Used when no recent document found
class NoRecentDocumentsState extends RecentDocsState {
  const NoRecentDocumentsState() : super._();

  @override
  List<Object?> get props => [];
}

/// Used to show recent documents list
class ShowRecentDocumentsState extends RecentDocsState {
  /// A list of the recent documents
  final List<RecentDocumentInfo> recentDocuments;

  /// `true` if more items can be fetched
  final bool hasMore;

  const ShowRecentDocumentsState(
    this.recentDocuments,
    this.hasMore,
  ) : super._();

  @override
  List<Object?> get props => [recentDocuments, hasMore];
}
