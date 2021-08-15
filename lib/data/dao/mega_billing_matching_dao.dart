import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/data/export/table_exporter.dart';
import 'package:kres_requests2/data/models.dart';
import 'package:kres_requests2/data/models/mega_billing_matching.dart';
import 'package:kres_requests2/data/persistence_exception.dart';
import 'package:kres_requests2/data/repository/encoder.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models/mega_billing_matching.dart';

import 'dao.dart';

class MegaBillingMatchingEncoder
    implements
        PersistedObjectSerializer<MegaBillingMatching,
            MegaBillingMatchingEntity> {
  final Dao<RequestType, RequestTypeEntity> _requestTypeDao;

  const MegaBillingMatchingEncoder(this._requestTypeDao);

  @override
  Future<PersistedObject> deserialize(Map<String, dynamic> data) async {
    final requestType = await _requestTypeDao.findById(data['request_type_id']);

    return MegaBillingMatchingEntity(
      data['id'],
      megaBillingNaming: data['name'],
      requestType: requestType ??
          const RequestTypeEntity(0, shortName: '???', fullName: '???'),
    );
  }

  @override
  Map<String, dynamic> serialize(MegaBillingMatching entity) {
    // Cascading is not allowed, so request type should be already inserted
    if (entity.requestType is! PersistedObject<int>) {
      throw PersistenceException.notPersisted();
    }

    return {
      if (this is PersistedObject<int>) 'id': (this as PersistedObject<int>).id,
      'name': entity.megaBillingNaming,
      'request_type_id': (entity.requestType as PersistedObject<int>).id,
    };
  }
}

/// Data access object for [MegaBillingMatching] objects
class MegaBillingMatchingDao
    extends BaseDao<MegaBillingMatching, MegaBillingMatchingEntity>
    with ExportableEntity {
  MegaBillingMatchingDao(
      AppDatabase database, Dao<RequestType, RequestTypeEntity> requestTypeDao)
      : super(
          MegaBillingMatchingEncoder(requestTypeDao),
          tableName: 'megabilling_type_assoc',
          database: database,
        );
}
