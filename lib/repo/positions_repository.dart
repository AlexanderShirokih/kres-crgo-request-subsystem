import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/models/position.dart';
import 'package:kres_requests2/repo/base_crud_repository.dart';

/// Repository for managing [Position]s
class PositionsRepository extends BaseCRUDRepository<Position> {
  PositionsRepository(
    ApiServer apiServer,
  ) : super(apiServer, 'positions');

  @override
  int getId(Position entity) => entity.id;

  @override
  Position fromJson(dynamic data) => Position.fromJson(data);

  @override
  toJson(Position entity) => entity.toJson();
}
