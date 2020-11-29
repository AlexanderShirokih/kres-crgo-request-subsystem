import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:kres_requests2/models/encoder.dart';
import 'package:kres_requests2/models/entity.dart';
import 'package:kres_requests2/models/position.dart';

/// Describes employee assignment types
enum AssignmentType { MEMBER, MAIN, CHIEF }

AssignmentType fromString(String type) {
  switch (type) {
    case 'MEMBER':
      return AssignmentType.MEMBER;
    case 'MAIN':
      return AssignmentType.MAIN;
    case 'CHIEF':
      return AssignmentType.CHIEF;
    default:
      throw ('Unknown AssignmentType value: $type');
  }
}

extension AssignmentTypeExt on AssignmentType {
  String value() => describeEnum(this);
}

/// Couples employee and assignment type
class EmployeeAssignment extends Equatable {
  /// Associated employee
  final Employee employee;

  /// Associated assignment type
  final AssignmentType type;

  const EmployeeAssignment({
    @required this.employee,
    @required this.type,
  }) : assert(employee != null);

  @override
  List<Object> get props => [employee, type];

  static EmployeeAssignment fromJson(Map<String, dynamic> data) =>
      EmployeeAssignment(
        employee: Employee.fromJson(data['employee']),
        type: data['type'] != null ? fromString(data['type']) : null,
      );

  @override
  bool get stringify => true;
}

enum EmployeeStatus { WORKS, FIRED }

/// Describes info about employee
class Employee extends Equatable implements Entity<int> {
  /// Internal employee ID
  final int id;

  /// Employee name
  final String name;

  /// Employee position
  final Position position;

  /// Electrical access group
  final int accessGroup;

  /// Is employee working or fired
  final EmployeeStatus status;

  const Employee({
    this.id,
    @required this.name,
    @required this.position,
    @required this.accessGroup,
    @required this.status,
  })  : assert(name != null),
        assert(status != null),
        assert(position != null),
        assert(accessGroup != null);

  static Encoder<Employee> encoder() => _EmployeeEncoder();

  /// Creates [Employee] instance from JSON data
  factory Employee.fromJson(Map<String, dynamic> data) =>
      encoder().fromJson(data);

  /// Converts [Employee] instance to JSON representation
  Map<String, dynamic> toJson() => encoder().toJson(this);

  @override
  List<Object> get props => [id, status, name, position, accessGroup];

  @override
  int getId() => id;

  @override
  String toString() => ' ${position.name} $name, $accessGroup гр.';
}

class _EmployeeEncoder extends Encoder<Employee> {
  const _EmployeeEncoder();

  @override
  Employee fromJson(Map<String, dynamic> data) => Employee(
        id: data['id'],
        name: data['name'],
        status: getStatusFromString(data['status']),
        position: Position.fromJson(data['position']),
        accessGroup: data['accessGroup'],
      );

  @override
  Map<String, dynamic> toJson(Employee e) => {
        'id': e.id,
        'name': e.name,
        'position': e.position.toJson(),
        'accessGroup': e.accessGroup,
        'status': describeEnum(e.status),
      };

  EmployeeStatus getStatusFromString(String type) {
    switch (type) {
      case 'WORKS':
        return EmployeeStatus.WORKS;
      case 'FIRED':
        return EmployeeStatus.FIRED;
    }
    throw ('Unknown EmployeeStatus: $type');
  }
}
