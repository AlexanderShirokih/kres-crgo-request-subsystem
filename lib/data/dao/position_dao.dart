import 'package:kres_requests2/data/models/position.dart';
import 'package:kres_requests2/data/repository/encoder.dart';
import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'dao.dart';

/// Converts [Position] instance to JSON representation
class PositionSerializer
    implements PersistedObjectSerializer<Position, PositionEntity> {
  const PositionSerializer();

  @override
  Future<PersistedObject> deserialize(Map<String, dynamic> data) =>
      Future.value(
        PositionEntity(
          data['id'],
          name: data['name'],
        ),
      );

  @override
  Map<String, dynamic> serialize(Position entity) => {
        if (entity is PersistedObject<int>)
          'id': (entity as PersistedObject<int>).id,
        'name': entity.name,
      };
}

/// Data access object for [Position] objects
class PositionDao extends BaseDao<Position, PositionEntity> {
  const PositionDao(Database database)
      : super(
          const PositionSerializer(),
          tableName: 'employee_position',
          database: database,
        );
}
