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

    final deleted = all.where((item) => !item.path.existsSync()).toList();

    if (deleted.isNotEmpty) {
      for (final toDelete in deleted) {
        await delete(toDelete);
        all.remove(toDelete);
      }
    }

    return all.cast<RecentDocumentEntity>()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  @override
  Future<RecentDocumentInfo> add(RecentDocumentInfo entity) async {
    final recentDao = dao as RecentDocumentsDao;

    // Last document is the same
    final last = await recentDao.findLast();

    if (last != null && last.path.path == entity.path.path) {
      return last;
    }

    // Check whether document was already opened
    final all = await recentDao.findAll();
    for (final dup in all.where((element) => element.path.path == entity.path.path)) {
      await recentDao.delete(dup);
    }

    final count = await dao.count();
    final toDelete = count - maxRecentDocsItems + 1;

    if (toDelete > 0) {
      await recentDao.deleteFirstN(toDelete);
    }

    return await super.add(entity);
  }
}
