/// Data class describing user
class User {
  /// Users name
  final String name;

  /// If `true` that user has moderation rights, `false` otherwise
  final bool hasModerationRights;

  const User({this.name, this.hasModerationRights})
      : assert(name != null),
        assert(hasModerationRights != null);
}
