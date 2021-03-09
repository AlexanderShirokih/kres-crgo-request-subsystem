import 'package:equatable/equatable.dart';

/// Describes employee position
class Position extends Equatable {
  /// Position name
  final String name;

  const Position({required this.name});

  @override
  List<Object> get props => [name];

  /// Creates a copy with customized parameters
  Position copy({String? name}) => Position(name: name ?? this.name);
}
