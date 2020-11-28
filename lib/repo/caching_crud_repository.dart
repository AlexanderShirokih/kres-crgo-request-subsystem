import 'package:async/async.dart';
import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/repo/base_crud_repository.dart';

/// Wrapper for CRUD repository that handles items caching
abstract class CachingCRUDRepository<E> extends BaseCRUDRepository<E> {
  final AsyncCache<List<E>> _dataCache;

  CachingCRUDRepository(
      Duration expirationTime, ApiServer apiServer, String requestPath)
      : assert(expirationTime != null),
        _dataCache = AsyncCache<List<E>>(expirationTime),
        super(apiServer, requestPath);

  @override
  Future<List<E>> getAll() => _dataCache.fetch(() => super.getAll());

  @override
  Future save(E entity) {
    _dataCache.invalidate();
    return super.save(entity);
  }

  @override
  Future delete(E entity) {
    _dataCache.invalidate();
    return super.delete(entity);
  }
}
