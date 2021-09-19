import 'dart:io';

import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/data/models/recent_document_info.dart';
import 'package:kres_requests2/data/repository/encoder.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models/request_type.dart';

import 'dao.dart';

/// Converts [RecentDocumentInfo] instance to JSON representation
class RecentDocumentsSerializer
    implements
        PersistedObjectSerializer<RecentDocumentInfo, RecentDocumentEntity> {
  const RecentDocumentsSerializer();

  @override
  Future<PersistedObject> deserialize(Map<String, dynamic> data) =>
      Future.value(
        RecentDocumentEntity(
          data['id'],
          path: File(data['path']),
        ),
      );

  @override
  Map<String, dynamic> serialize(RecentDocumentInfo entity) => {
        if (entity is PersistedObject<int>)
          'id': (entity as PersistedObject<int>).id,
        'path': entity.path.absolute.path,
      };
}

/// Data access object for [RequestType] objects
class RecentDocumentsDao
    extends BaseDao<RecentDocumentInfo, RecentDocumentEntity> {
  const RecentDocumentsDao(AppDatabase database)
      : super(
          const RecentDocumentsSerializer(),
          tableName: 'recent_documents',
          database: database,
        );

  /// Deletes first `N` elements from the table
  Future<void> deleteFirstN(int n) async {
    final db = await database.database;
    await db.rawDelete(
        'DELETE FROM $tableName\n'
        'WHERE id IN (SELECT id FROM $tableName LIMIT ?)',
        [n]);
  }
}
