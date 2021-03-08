import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/models/position.dart';

class PositionEntity extends Position implements PersistedObject<int> {
  @override
  final int id;

  PositionEntity(this.id, {required String name}) : super(name);

  @override
  List<Object> get props => [...super.props, id];
}
