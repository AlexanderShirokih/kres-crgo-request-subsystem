import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/position.dart';

/// Creates [PersistedObjectBuilder] factory that creates new persisted entities
class EmployeePersistedBuilder implements PersistedObjectBuilder<Employee> {
  const EmployeePersistedBuilder();

  @override
  Employee build(key, Employee entity) => EmployeeEntity(
        key,
        name: entity.name,
        position: entity.position,
        accessGroup: entity.accessGroup,
      );
}

/// Employee data object for storing in database
class EmployeeEntity extends Employee implements PersistedObject<int> {
  @override
  final int id;

  const EmployeeEntity(
    this.id, {
    required String name,
    required Position position,
    required int accessGroup,
  }) : super(
          name: name,
          position: position,
          accessGroup: accessGroup,
        );

  @override
  List<Object?> get props => [id, ...super.props];

  @override
  Employee copy({
    String? name,
    Position? position,
    int? accessGroup,
  }) =>
      EmployeeEntity(
        id,
        name: name ?? this.name,
        position: position ?? this.position,
        accessGroup: accessGroup ?? this.accessGroup,
      );
}
