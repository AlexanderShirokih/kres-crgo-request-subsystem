import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// Repository implementation for managing [RequestEntity]'s in locale paged
/// scope
// TODO: INSTANCE SHOULD BE PER page
class PageRequestRepository extends Repository<RequestEntity> {
  @override
  Future<RequestEntity> add(RequestEntity entity) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<void> delete(RequestEntity entity) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<RequestEntity>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future<void> update(RequestEntity entity) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
