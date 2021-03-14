import 'package:kres_requests2/data/models/request_type.dart';
import 'package:kres_requests2/data/repository/encoder.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'dao.dart';

/// Converts [RequestType] instance to JSON representation
class RequestTypeSerializer
    implements PersistedObjectSerializer<RequestType, RequestTypeEntity> {
  const RequestTypeSerializer();

  @override
  Future<PersistedObject> deserialize(Map<String, dynamic> data) =>
      Future.value(
        RequestTypeEntity(
          data['id'],
          shortName: data['short_name'],
          fullName: data['full_name'],
        ),
      );

  @override
  Map<String, dynamic> serialize(RequestType entity) => {
        if (entity is PersistedObject<int>)
          'id': (entity as PersistedObject<int>).id,
        'short_name': entity.shortName,
        'full_name': entity.fullName,
      };
}

/// Data access object for [RequestType] objects
class RequestTypeDao extends BaseDao<RequestType, RequestTypeEntity> {
  const RequestTypeDao(Database database)
      : super(
          const RequestTypeSerializer(),
          tableName: 'request_type',
          database: database,
        );
}
