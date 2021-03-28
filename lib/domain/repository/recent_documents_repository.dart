import 'package:kres_requests2/data/dao/recent_documents_dao.dart';
import 'package:kres_requests2/data/models/recent_document_info.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
import 'package:kres_requests2/domain/domain.dart';

/// Repository interface for managing [RecentDocumentInfo]s
class RecentDocumentsRepository extends PersistedStorageRepository<
    RecentDocumentInfo, RecentDocumentEntity> {
  static const maxRecentDocsItems = 10;

  RecentDocumentsRepository(RecentDocumentsDao recentDocsDao)
      : super(recentDocsDao);

  @override
  Future<List<RecentDocumentInfo>> getAll() async {
    final all = await super.getAll();
    return all.cast<RecentDocumentEntity>()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  @override
  Future<RecentDocumentInfo> add(RecentDocumentInfo entity) async {
    final recentDao = dao as RecentDocumentsDao;
    final last = await recentDao.findLast();

    if (last != null && last.path.path == entity.path.path) {
      return last;
    }

    final count = await dao.count();
    final toDelete = count - maxRecentDocsItems + 1;

    if (toDelete > 0) {
      await recentDao.deleteFirstN(toDelete);
    }

    return await super.add(entity);
  }
}
