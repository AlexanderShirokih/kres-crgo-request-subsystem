class Street {
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

  static Street fromJson(Map<String, dynamic> data) => Street(
        id: data['id'],
        name: data['name'],
        district: data['district'] == null
            ? null
            : District.fromJson(data['district']),
      );
}

/// Describes city district
class District {
  /// Internal ID
  final int id;

  /// District name
  final String name;

  const District({
    this.id,
    this.name,
  });

  static District fromJson(Map<String, dynamic> data) => District(
        id: data['id'],
        name: data['name'],
      );
}
