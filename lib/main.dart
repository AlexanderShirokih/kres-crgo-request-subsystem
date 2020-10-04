import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kres_requests2/data/employee.dart';
import 'package:kres_requests2/repo/employees_repository.dart';

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
          RepositoryProvider.value(
            value: EmployeesRepository(
              (jsonDecode(File("employees.json").readAsStringSync())
                      as List<dynamic>)
                  .map((e) => Employee.fromJson(e))
                  .toList(),
            ),
          )
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
