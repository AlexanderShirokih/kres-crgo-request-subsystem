import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/repo/settings_repository.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsRepository settingsRepository;

  const SettingsScreen({Key key, this.settingsRepository}) : super(key: key);

  static Route createRoute(RepositoryModule reposModule) => MaterialPageRoute(
        builder: (_) => SettingsScreen(
            settingsRepository: reposModule.getSettingsRepository()),
      );

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Настройки'),
        ),
        body: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500.0),
          child: ListView(
            padding: const EdgeInsets.all(12.0),
            children: [_itemJavaPath()],
          ),
        ),
      );

  Widget _itemJavaPath() => ListTile(
        leading: FaIcon(FontAwesomeIcons.java),
        title: Text('Путь к Java (JAVA_HOME)'),
        subtitle: Text(_getCurrentJavaPath()),
        onTap: () => _showJavaPathSelector().then((newPath) {
          if (newPath != null) {
            setState(() {
              widget.settingsRepository.javaPath = newPath;
            });
          }
        }),
      );

  String _getCurrentJavaPath() {
    final path = widget.settingsRepository.javaPath;
    if (path == null) return '(Не установлено)';
    final filePath = Directory(path).absolute;
    if (!filePath.existsSync()) {
      print("PATH=${filePath.path} is NOT EXISTS!");
      return '(Не существует!)';
    }
    return path;
  }

  Future<String> _showJavaPathSelector() => showOpenPanel(
        canSelectDirectories: true,
        confirmButtonText: 'Выбрать',
      ).then((res) => res.canceled ? null : res.paths[0]);
}
