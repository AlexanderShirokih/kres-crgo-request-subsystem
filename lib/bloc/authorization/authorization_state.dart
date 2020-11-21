part of 'authorization_bloc.dart';

/// Common state for authorization BLoC
abstract class AuthorizationState extends Equatable {
  const AuthorizationState();
}

/// Initial state that displays login form
class AuthorizationInitial extends AuthorizationState {
  @override
  List<Object> get props => [];
}

/// State that indicates authorization is processing
class AuthorizationProcessing extends AuthorizationState {
  @override
  List<Object> get props => [];
}

/// State that used when authorization completed successfully
class AuthorizationFinished extends AuthorizationState {
  final User user;

  const AuthorizationFinished(this.user) : assert(user != null);

  @override
  List<Object> get props => [user];
}

/// State that used that authorization failed
class AuthorizationFailed extends AuthorizationState {
  @override
  List<Object> get props => [];
}

/// Indicates error during authorization
class AuthorizationError extends AuthorizationState {
  final String errorMessage;

  const AuthorizationError(this.errorMessage) : assert(errorMessage != null);

  @override
  List<Object> get props => [errorMessage];
}
