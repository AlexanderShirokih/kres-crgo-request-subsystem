import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/models/request.dart';
import 'package:kres_requests2/repo/base_crd_repository.dart';

/// Class for managing request types
class RequestTypeRepository extends BaseCRDRepository<RequestType> {
  RequestTypeRepository(
    ApiServer apiServer,
  ) : super(apiServer, 'requests/types');

  @override
  int getId(RequestType entity) => entity.id;

  @override
  RequestType fromJson(dynamic data) => RequestType.fromJson(data);

  @override
  toJson(RequestType entity) => entity.toJson();
}
