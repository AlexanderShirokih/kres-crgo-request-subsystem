import 'package:flutter/material.dart';

import 'package:kres_requests2/application_module.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/data/models/credentials.dart';
import 'package:kres_requests2/screens/auth/authorization_screen.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:window_control/window_control.dart';

// Short entry point for debug purposes
void main() => runApp(MyApp());

/// Application root class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Warm up [WindowControl] instance
    WindowControl.instance;

    return FutureBuilder<ApplicationModule>(
      future: _injectRootModule(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: ErrorView(errorDescription: snapshot.error.toString()),
          );
        } else if (snapshot.hasData) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Заявки КРЭС 2.0',
            theme:
                ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
            home: AuthorizationScreen(
              repositoryModule: snapshot.data.getRepositoryModule(),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<ApplicationModule> _injectRootModule() =>
      ApplicationModule().init(_MockedCredentialsManager());
}

class _MockedCredentialsManager implements CredentialsManager {
  @override
  Credentials getCredentials() => Credentials('test_admin', 'password');

  @override
  void setCredentials(Credentials credentials) {}
}
