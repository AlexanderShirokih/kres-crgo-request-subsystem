import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/app_module.dart';

void main() => runApp(ModularApp(module: AppModule(), child: MyApp()));

/// Application root class
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('ru', ''),
        ],
        title: 'Заявки КРЭС 2.0',
        theme: ThemeData(
          primaryColor: Colors.blue,
          accentColor: Colors.deepOrange,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
      ).modular();
}
