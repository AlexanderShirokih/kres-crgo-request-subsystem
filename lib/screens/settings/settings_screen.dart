import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/settings/settings_module.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/screens/settings/employees/employees_screen.dart';
import 'package:kres_requests2/screens/settings/positions/positions_screen.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsModule settingsModule;
  final SettingsRepository settingsRepository;

  const SettingsScreen({
    Key? key,
    required this.settingsModule,
    required this.settingsRepository,
  }) : super(key: key);

  static Route createRoute(
    RepositoryModule reposModule,
    SettingsModule settingsModule,
  ) =>
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          settingsModule: settingsModule,
          settingsRepository: reposModule.getSettingsRepository(),
        ),
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
            children: [
              _itemJavaPath(),
              // TODO: Navigate throught Router!
              _navigableItem(
                context,
                'Сотрудники',
                () => EmployeesScreen(
                  employeeModule: widget.settingsModule.employeeModule,
                  positionModule: widget.settingsModule.positionModule,
                ),
              ),
              _navigableItem(
                context,
                'Должности',
                    () => PositionsScreen(
                      positionModule: widget.settingsModule.positionModule,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _navigableItem(
          BuildContext context, String title, Widget Function() builder) =>
      ListTile(
        leading: FaIcon(FontAwesomeIcons.cog),
        title: Text(title),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => builder())),
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

  Future<String?> _showJavaPathSelector() => getDirectoryPath(
        confirmButtonText: 'Выбрать',
      );
}
