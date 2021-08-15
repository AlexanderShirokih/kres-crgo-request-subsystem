import 'package:kres_requests2/data/dao/dao.dart';
import 'package:kres_requests2/data/models/mega_billing_matching.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
import 'package:kres_requests2/domain/models/mega_billing_matching.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:list_ext/list_ext.dart';

/// Repository interface for managing [MegaBillingMatching]s
class MegaBillingMatchingRepository extends PersistedStorageRepository<
    MegaBillingMatching, MegaBillingMatchingEntity> {
  MegaBillingMatchingRepository(
      Dao<MegaBillingMatching, MegaBillingMatchingEntity>
          megaBillingMatchingDao)
      : super(megaBillingMatchingDao);

  /// Finds [RequestType] by mega-billing request name. Returns `null` if
  /// there is no matching found
  Future<RequestType?> findByName(String name) async {
    final rows = await getAll();
    return rows
        .where((element) => element.megaBillingNaming == name)
        .map((e) => e.requestType)
        .firstOrNull;
  }

}
