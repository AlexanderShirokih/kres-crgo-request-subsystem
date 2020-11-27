import 'package:equatable/equatable.dart';
import 'package:kres_requests2/models/encoder.dart';
import 'package:kres_requests2/models/entity.dart';

/// Describes info about employee position
class Position extends Equatable implements Entity<int> {
  /// Internal ID
  final int id;

  /// Position name
  final String name;

  const Position({
    this.id,
    this.name,
  });

  /// Converts JSON to [Position] instance
  static Position fromJson(Map<String, dynamic> data) =>
      encoder().fromJson(data);

  @override
  List<Object> get props => [id, name];

  dynamic toJson() => encoder().toJson(this);

  @override
  int getId() => id;

  @override
  String toString() => name;

  static Encoder<Position> encoder() => _PositionEncoder();
}

class _PositionEncoder extends Encoder<Position> {
  const _PositionEncoder();

  @override
  Position fromJson(Map<String, dynamic> data) => Position(
        id: data['id'],
        name: data['name'],
      );

  @override
  Map<String, dynamic> toJson(Position e) => {
        'id': e.id,
        'name': e.name,
      };
}
