import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'position.dart';

/// Used to convert access group to its roman value
extension RomanGroupExtension on int {
  String get romanGroup {
    switch (this) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      case 5:
        return 'V';
      default:
        return toString();
    }
  }
}

/// Describes info about employee
class Employee extends Equatable {
  /// Employee name
  final String name;

  /// Employee position
  final Position position;

  /// Electrical access group
  final int accessGroup;

  Employee({
    @required this.name,
    @required this.position,
    @required this.accessGroup,
  })  : assert(name != null),
        assert(position != null),
        assert(accessGroup != null);

  /// Creates deep copy with customizable params
  Employee copy({
    String /*?*/ name,
    Position /*?*/ position,
    int /*?*/ accessGroup,
  }) {
    return Employee(
      name: name ?? this.name,
      position: position ?? this.position,
      accessGroup: accessGroup ?? this.accessGroup,
    );
  }

  @override
  List<Object> get props => [name, position, accessGroup];
}
