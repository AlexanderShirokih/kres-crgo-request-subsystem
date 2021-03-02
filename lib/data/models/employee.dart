import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/models/employee.dart';
import 'package:kres_requests2/domain/models/position.dart';
import 'package:meta/meta.dart';

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

class EmployeeEntity extends Employee implements PersistedObject<int> {
  @override
  final int id;

  EmployeeEntity(
    this.id, {
    @required String name,
    @required Position position,
    @required int accessGroup,
  }) : super(
          name: name,
          position: position,
          accessGroup: accessGroup,
        );

  @override
  List<Object> get props => [id, ...super.props];
}
