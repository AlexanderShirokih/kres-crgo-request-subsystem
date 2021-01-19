import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/startup/startup_screen.dart';

import 'package:window_control/window_control.dart';

void main() => runApp(MyApp());

/// Application root class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Warm up [WindowControl] instance
    WindowControl.instance;

    return FutureBuilder<RepositoryModule>(
      future: _loadRepositories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: ErrorView(errorDescription: snapshot.error.toString()),
          );
        } else if (snapshot.hasData) {
          return RepositoryProvider.value(
            value: snapshot.data,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Заявки КРЭС 2.0',
              theme: ThemeData(
                  visualDensity: VisualDensity.adaptivePlatformDensity),
              home: StartupScreen(),
            ),
          );
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<RepositoryModule> _loadRepositories() =>
      RepositoryModule.buildRepositoryModule();
}
