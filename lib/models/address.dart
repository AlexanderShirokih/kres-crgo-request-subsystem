import 'package:equatable/equatable.dart';
import 'package:kres_requests2/models/encoder.dart';
import 'package:kres_requests2/models/entity.dart';

class Street extends Equatable implements Entity<int> {
  /// Internal ID
  final int id;

  /// Street name
  final String name;

  /// Optional district id
  final District district;

  const Street({
    this.id,
    this.name,
    this.district,
  });

  static Street fromJson(Map<String, dynamic> data) => encoder().fromJson(data);

  static Encoder<Street> encoder() => _StreetEncoder();

  Map<String, dynamic> toJson() => encoder().toJson(this);

  @override
  int getId() => id;

  @override
  List<Object> get props => [id, name, district];
}

class _StreetEncoder extends Encoder<Street> {
  const _StreetEncoder();

  @override
  Street fromJson(Map<String, dynamic> data) => Street(
        id: data['id'],
        name: data['name'],
        district: data['district'] == null
            ? null
            : District.fromJson(data['district']),
      );

  @override
  Map<String, dynamic> toJson(Street e) => {
        'id': e.id,
        'name': e.name,
        'district': e.district?.toJson(),
      };
}

/// Describes city district
class District extends Equatable implements Entity<int> {
  /// Internal ID
  final int id;

  /// District name
  final String name;

  const District({
    this.id,
    this.name,
  });

  static District fromJson(Map<String, dynamic> data) =>
      encoder().fromJson(data);

  static Encoder<District> encoder() => _DistrictEncoder();

  Map<String, dynamic> toJson() => encoder().toJson(this);

  @override
  int getId() => id;

  @override
  List<Object> get props => [id, name];
}

class _DistrictEncoder extends Encoder<District> {
  const _DistrictEncoder();

  @override
  District fromJson(Map<String, dynamic> data) => District(
        id: data['id'],
        name: data['name'],
      );

  @override
  Map<String, dynamic> toJson(District e) => {
        'id': e.id,
        'name': e.name,
      };
}
