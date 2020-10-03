import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/repo/config_repository.dart';
import 'package:kres_requests2/screens/startup/startup_screen.dart';

void main() => runApp(MyApp());

/// Application root class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: SettingsRepository()),
          RepositoryProvider.value(value: ConfigRepository()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Заявки КРЭС 2.0',
          theme:
              ThemeData(visualDensity: VisualDensity.adaptivePlatformDensity),
          home: StartupScreen(),
        ),
      );
}
