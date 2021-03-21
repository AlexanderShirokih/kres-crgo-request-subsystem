import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/app_module.dart';

void main() => runApp(ModularApp(module: AppModule(), child: MyApp()));

/// Application root class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Заявки КРЭС 2.0',
        theme: ThemeData(
          primaryColor: Colors.blue,
          accentColor: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ).modular();
}
