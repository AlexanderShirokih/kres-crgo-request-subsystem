import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/models/position.dart';
import 'package:kres_requests2/repo/caching_crud_repository.dart';

/// Repository for managing [Position]s
class PositionsRepository extends CachingCRUDRepository<Position> {
  PositionsRepository(
    ApiServer apiServer,
  ) : super(const Duration(hours: 1), apiServer, 'positions');

  @override
  int getId(Position entity) => entity.id;

  @override
  Position fromJson(dynamic data) => Position.fromJson(data);

  @override
  toJson(Position entity) => entity.toJson();
}
