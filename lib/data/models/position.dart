import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/models/position.dart';

/// Creates [PersistedObjectBuilder] factory that creates new persisted entities
class PositionPersistedBuilder implements PersistedObjectBuilder<Position> {
  const PositionPersistedBuilder();

  @override
  Position build(key, Position entity) => PositionEntity(
        key,
        name: entity.name,
      );
}

/// Position data object for storing in database
class PositionEntity extends Position implements PersistedObject<int> {
  @override
  final int id;

  PositionEntity(this.id, {required String name}) : super(name: name);

  @override
  List<Object> get props => [...super.props, id];

  @override
  Position copy({String? name}) => PositionEntity(id, name: name ?? this.name);
}
