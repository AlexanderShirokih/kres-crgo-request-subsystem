import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/models/request.dart';
import 'package:kres_requests2/repo/base_crud_repository.dart';

/// Class for managing [RequestType]s
class RequestTypeRepository extends BaseCRUDRepository<RequestType> {
  RequestTypeRepository(
    ApiServer apiServer,
  ) : super(apiServer, RequestType.encoder(), 'requests/types');
}
