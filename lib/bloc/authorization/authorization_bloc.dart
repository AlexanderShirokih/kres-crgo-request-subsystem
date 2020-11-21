import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/data/models/credentials.dart';
import 'package:kres_requests2/repo/server_exception.dart';
import 'package:kres_requests2/repo/users_repository.dart';

part 'authorization_event.dart';

part 'authorization_state.dart';

class AuthorizationBloc extends Bloc<AuthorizationEvent, AuthorizationState> {
  final UsersRepository _usersRepository;
  final CredentialsManager _credentialsManager;

  AuthorizationBloc(this._usersRepository, this._credentialsManager)
      : assert(_usersRepository != null),
        assert(_credentialsManager != null),
        super(AuthorizationInitial());

  @override
  Stream<AuthorizationState> mapEventToState(
    AuthorizationEvent event,
  ) async* {
    if (event is AuthorizationSignInEvent) {
      yield* _handleAuthEvent(event);
    }
  }

  Stream<AuthorizationState> _handleAuthEvent(
      AuthorizationSignInEvent event) async* {
    // Begin authorization attempt
    yield AuthorizationProcessing();

    // Update the credentials
    _credentialsManager
        .setCredentials(Credentials(event.login, event.password));

    try {
      await _usersRepository.getUserDetails();
      yield AuthorizationFinished();
    } on UnauthorizedException {
      // Empty string indicated authorization error
      yield AuthorizationFailed();
      yield AuthorizationInitial();
    } on ApiException catch (apiException) {
      yield AuthorizationError(apiException.message);
      yield AuthorizationInitial();
    }
  }
}
