import 'package:equatable/equatable.dart';

import 'position.dart';

/// Describes info about employee
class Employee extends Equatable {
  /// Employee name
  final String name;

  /// Employee position
  final Position position;

  /// Electrical access group
  final int accessGroup;

  const Employee({
    required this.name,
    required this.position,
    required this.accessGroup,
  });

  /// Creates deep copy with customizable params
  Employee copy({
    String? name,
    Position? position,
    int? accessGroup,
  }) {
    return Employee(
      name: name ?? this.name,
      position: position ?? this.position,
      accessGroup: accessGroup ?? this.accessGroup,
    );
  }

  @override
  List<Object?> get props => [name, position, accessGroup];
}
