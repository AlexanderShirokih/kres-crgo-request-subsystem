import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/models/address.dart';
import 'package:kres_requests2/repo/base_crud_repository.dart';

/// Repository class for managing city districts
class DistrictRepository extends BaseCRUDRepository<District> {
  DistrictRepository(ApiServer apiServer)
      : super(apiServer, District.encoder(), 'districts');
}
