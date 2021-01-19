import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Describes info about employee
class Employee extends Equatable {
  /// Internal employee ID used by database
  int id;

  /// Employee name
  final String name;

  /// Employee position
  final String position;

  /// Electrical access group
  final int accessGroup;

  Employee({
    @required this.name,
    @required this.position,
    @required this.accessGroup,
  })  : assert(name != null),
        assert(position != null),
        assert(accessGroup != null);

  /// Creates [Employee] instance from JSON data
  factory Employee.fromJson(Map<String, dynamic> data) => Employee(
        name: data['name'],
        position: data['position'],
        accessGroup: data['accessGroup'],
      );

  /// Converts [Employee] instance to JSON representation
  Map<String, dynamic> toJson() => {
        'name': name,
        'position': position,
        'accessGroup': accessGroup,
      };

  @override
  List<Object> get props => [name, position, accessGroup];
}
