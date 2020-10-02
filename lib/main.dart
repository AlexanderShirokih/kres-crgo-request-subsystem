import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/screens/startup/startup_screen.dart';

import 'repo/config_repository.dart';
import 'repo/worksheet_repository.dart';

void main() => runApp(MyApp());

/// Application root class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(
              value: WorksheetRepository('requests/bin/Requests2.0')),
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
