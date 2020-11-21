import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/bloc/authorization/authorization_bloc.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/startup/startup_screen.dart';
import 'package:window_control/window_listener.dart';

import 'login_form.dart';

/// An authorization screen. Shows at startup for unauthorized users.
class AuthorizationScreen extends StatelessWidget {
  final AuthorizationBloc _authorizationBloc;

  AuthorizationScreen({Key key, RepositoryModule repositoryModule})
      : assert(repositoryModule != null),
        _authorizationBloc = AuthorizationBloc(
          repositoryModule.getUserRepository(),
          repositoryModule.getCredentialsManager(),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: WindowListener(
        onWindowClosing: () => Future.value(true),
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 600.0,
              maxHeight: 450.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(24.0),
              ),
              padding: const EdgeInsets.all(32.0),
              child: BlocConsumer<AuthorizationBloc, AuthorizationState>(
                cubit: _authorizationBloc,
                builder: (context, state) {
                  if (state is AuthorizationInitial) {
                    return _buildAuthDialog(context);
                  } else if (state is AuthorizationProcessing) {
                    return LoadingView('Загрузка данных...');
                  } else
                    return LoadingView();
                },
                listener: (context, state) {
                  if (state is AuthorizationFailed) {
                    _showError(context, null);
                  } else if (state is AuthorizationError) {
                    _showError(context, state.errorMessage);
                  } else if (state is AuthorizationFinished) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => StartupScreen()),
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Shows view with authorization dialog
  Widget _buildAuthDialog(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Вход в систему',
            style: Theme.of(context).textTheme.headline3.copyWith(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 80.0),
          LogInFormView(
            onLoginFormEntered: (String login, String password) =>
                _authorizationBloc
                    .add(AuthorizationSignInEvent(login, password)),
          )
        ],
      );

  void _showError(BuildContext context, String errorMessage) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage == null
              ? 'Не удалось войти в систему.'
              : 'Произошла ошибка: $errorMessage'),
        ),
      );
}
