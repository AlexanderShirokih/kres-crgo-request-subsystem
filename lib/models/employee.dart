import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
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
}

/// Describes info about employee
class Employee extends Equatable {
  /// Internal employee ID
  final int id;

  /// Employee name
  final String name;

  /// Employee position
  final Position position;

  /// Electrical access group
  final int accessGroup;

  const Employee({
    this.id,
    @required this.name,
    @required this.position,
    @required this.accessGroup,
  })  : assert(name != null),
        assert(position != null),
        assert(accessGroup != null);

  /// Creates [Employee] instance from JSON data
  factory Employee.fromJson(Map<String, dynamic> data) => Employee(
        id: data['id'],
        name: data['name'],
        position: Position.fromJson(data['position']),
        accessGroup: data['accessGroup'],
      );

  /// Converts [Employee] instance to JSON representation
  Map<String, dynamic> toJson() => {
        'name': name,
        'position': position,
        'accessGroup': accessGroup,
      };

  @override
  List<Object> get props => [id, name, position, accessGroup];
}
