import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kres_requests2/data/employee.dart';
import 'package:kres_requests2/repo/employees_repository.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/repo/config_repository.dart';
import 'package:kres_requests2/screens/startup/startup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/common.dart';

void main() => runApp(MyApp());

/// Application root class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FutureBuilder<dynamic>(
        future: _loadRepositories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: ErrorView(errorDescription: snapshot.error.toString()),
            );
          } else if (snapshot.hasData) {
            return MultiRepositoryProvider(
              providers: snapshot.data,
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

  Future<dynamic> _loadRepositories() async => [
        RepositoryProvider.value(value: ConfigRepository()),
        RepositoryProvider.value(
          value: SettingsRepository.fromPreferences(
            await SharedPreferences.getInstance(),
          ),
        ),
        RepositoryProvider.value(
          value: EmployeesRepository(
            (jsonDecode(await File("employees.json").readAsString())
                    as List<dynamic>)
                .map((e) => Employee.fromJson(e))
                .toList(),
          ),
        )
      ];
}
