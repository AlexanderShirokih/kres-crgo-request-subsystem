import 'package:equatable/equatable.dart';

/// Describes info about employee position
class Position extends Equatable {
  /// Internal ID
  final int id;

  /// Position name
  final String name;

  const Position({
    this.id,
    this.name,
  });

  /// Converts JSON to `Position` instance
  static Position fromJson(Map<String, dynamic> data) => Position(
        id: data['id'],
        name: data['name'],
      );

  @override
  List<Object> get props => [id, name];
}
