import 'package:flutter/material.dart';
import 'package:kres_requests2/application_module.dart';
import 'package:kres_requests2/data/credentials_manager.dart';
import 'package:kres_requests2/screens/auth/authorization_screen.dart';
import 'package:kres_requests2/screens/common.dart';

void main() => runApp(MyApp());

/// Application root class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      ApplicationModule().init(CredentialsManagerImpl());
}
