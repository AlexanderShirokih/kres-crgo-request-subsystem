import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/models/counting_point.dart';
import 'package:kres_requests2/repo/caching_crud_repository.dart';

/// Repository class for managing [CounterType]s
class CounterTypesRepository extends CachingCRUDRepository<CounterType> {
  CounterTypesRepository(ApiServer apiServer)
      : super(
          const Duration(hours: 1),
          apiServer,
          CounterType.encoder(),
          'counters',
        );
}
