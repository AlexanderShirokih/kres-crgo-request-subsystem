import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/startup/startup_screen.dart';
import 'package:window_control/window_control.dart';

import 'app_module.dart';

void main() => runApp(MyApp());

/// Application root class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Warm up [WindowControl] instance
    WindowControl.instance;

    return FutureBuilder<AppModule>(
      future: AppModule.build(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: ErrorView(errorDescription: snapshot.error.toString()),
          );
        } else if (snapshot.hasData) {
          return RepositoryProvider<RepositoryModule>.value(
            value: snapshot.data.repositoryModule,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Заявки КРЭС 2.0',
              theme: ThemeData(
                primaryColor: Colors.blue,
                accentColor: Colors.deepOrange,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              home: StartupScreen(appModule: snapshot.data),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
