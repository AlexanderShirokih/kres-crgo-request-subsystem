part of 'authorization_bloc.dart';

abstract class AuthorizationEvent extends Equatable {
  const AuthorizationEvent();
}

/// Used to fire sign-in event
class AuthorizationSignInEvent extends AuthorizationEvent {
  final String login;
  final String password;

  const AuthorizationSignInEvent(this.login, this.password)
      : assert(login != null),
        assert(password != null);

  @override
  List<Object> get props => [login, password];
}
