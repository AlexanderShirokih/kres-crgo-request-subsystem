import 'dart:io';

import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/domain.dart';

/// Creates [PersistedObjectBuilder] factory that creates new persisted recent
/// documents
class RecentDocumentBuilder
    implements PersistedObjectBuilder<RecentDocumentInfo> {
  const RecentDocumentBuilder();

  @override
  RecentDocumentInfo build(key, RecentDocumentInfo entity) =>
      RecentDocumentEntity(
        key,
        path: entity.path,
      );
}

/// Recent document data object for storing in database
class RecentDocumentEntity extends RecentDocumentInfo
    implements PersistedObject<int> {
  @override
  final int id;

  const RecentDocumentEntity(this.id, {required File path}) : super(path: path);

  @override
  List<Object?> get props => [id, ...super.props];
}
