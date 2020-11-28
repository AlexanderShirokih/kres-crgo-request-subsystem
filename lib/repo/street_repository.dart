import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/models/address.dart';
import 'package:kres_requests2/repo/caching_crud_repository.dart';

/// Repository class for managing [Street]s
class StreetRepository extends CachingCRUDRepository<Street> {
  StreetRepository(ApiServer apiServer)
      : super(
          const Duration(hours: 1),
          apiServer,
          Street.encoder(),
          'streets',
        );
}
