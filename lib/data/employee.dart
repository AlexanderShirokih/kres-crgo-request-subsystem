import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

/// Describes info about employee
class Employee extends Equatable {
  /// Employee name
  final String name;

  /// Employee position
  final String position;

  /// Electrical access group
  final int elAccessGroup;

  const Employee({
    @required this.name,
    @required this.position,
    @required this.elAccessGroup,
  })  : assert(name != null),
        assert(position != null),
        assert(elAccessGroup != null);

  /// Creates [Employee] instance from JSON data
  factory Employee.fromJson(Map<String, dynamic> data) => Employee(
        name: data['name'],
        position: data['position'],
        elAccessGroup: data['elAccessGroup'],
      );

  @override
  List<Object> get props => [name, position, elAccessGroup];
}
