import 'package:equatable/equatable.dart';
import 'package:kres_requests2/models/encoder.dart';
import 'package:kres_requests2/models/entity.dart';

enum UserAuthority { GUEST, USER, MODERATOR, ADMIN }

const _kAuthorities = ['GUEST', 'USER', 'MODERATOR', 'ADMIN'];

extension UserAuthorityExt on UserAuthority {
  /// Returns text value of authority
  String description() {
    return _kAuthorities[index];
  }

  static const _kNames = [
    'Гость',
    'Пользователь',
    'Модератор',
    'Администратор'
  ];

  String getLocalizedDescription() => _kNames[index];

  static UserAuthority of(String authority) {
    for (int i = 0; i < _kAuthorities.length; i++) {
      if (_kAuthorities[i] == authority) return UserAuthority.values[i];
    }
    return null;
  }
}

/// Data class describing user
class User extends Equatable implements Entity<String> {
  /// Users name
  final String name;

  /// User access level
  final UserAuthority authority;

  /// User password (Used to create account or update existing password)
  final String password;

  const User({this.name, this.authority, this.password})
      : assert(name != null),
        assert(authority != null);

  @override
  String getId() => name;

  @override
  List<Object> get props => [name, authority, password];

  static Encoder<User> encoder() => _UserEncoder();

  /// Returns `true` is user has moderator privileges
  bool isModerator() => _atLeastAuthority(UserAuthority.MODERATOR);

  /// Returns `true` is user has admin privileges
  bool isAdmin() => _atLeastAuthority(UserAuthority.ADMIN);

  bool _atLeastAuthority(UserAuthority requested) =>
      authority.index >= requested.index;

  Map<String, dynamic> toJson() => encoder().toJson(this);

  static List<UserAuthority> allowedAuthorities() =>
      [UserAuthority.USER, UserAuthority.MODERATOR];
}

class _UserEncoder extends Encoder<User> {
  const _UserEncoder();

  @override
  User fromJson(Map<String, dynamic> data) => User(
        name: data['name'],
        authority: UserAuthorityExt.of(data['authority']),
        password: data['password'],
      );

  @override
  Map<String, dynamic> toJson(User e) => {
        'name': e.name,
        'authority': e.authority.description(),
        'password': e.password,
      };
}
