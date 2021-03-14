import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/data/settings/settings_module.dart';
import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/screens/settings/employees/employees_screen.dart';
import 'package:kres_requests2/screens/settings/positions/positions_screen.dart';

import 'java_path_selector/java_path_selector_screen.dart';

/// The settings screen. Provides access to main app preference tables and
/// ability to configure main parameters.
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

class _NavigableItem extends Equatable {
  final Widget icon;
  final String title;
  final Widget Function() builder;

  const _NavigableItem({
    required this.icon,
    required this.title,
    required this.builder,
  });

  @override
  List<Object?> get props => [icon, title, builder];
}

class _SettingsScreenState extends State<SettingsScreen> {
  int? _currentItem;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavigableItem(
        icon: Icon(Icons.work),
        title: 'Сотрудники',
        builder: () => EmployeesScreen(
          employeeModule: widget.settingsModule.employeeModule,
          positionModule: widget.settingsModule.positionModule,
        ),
      ),
      _NavigableItem(
        icon: Icon(Icons.badge),
        title: 'Должности',
        builder: () => PositionsScreen(
          positionModule: widget.settingsModule.positionModule,
        ),
      ),
      _NavigableItem(
        icon: FaIcon(FontAwesomeIcons.java),
        title: 'Путь к Java (JAVA_HOME)',
        builder: () => JavaPathSelectorScreen(
          settingsRepository: widget.settingsRepository,
        ),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Настройки'),
      ),
      body: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 340.0),
            child: ListView(
              padding: const EdgeInsets.all(12.0),
              children: List.generate(items.length, (index) {
                final current = items[index];
                return _navigableItem(
                  context,
                  position: index,
                  icon: current.icon,
                  title: current.title,
                  builder: current.builder,
                );
              }),
            ),
          ),
          Expanded(
            child: _currentItem == null
                ? SizedBox()
                : items[_currentItem!].builder(),
          ),
        ],
      ),
    );
  }

  Widget _navigableItem(
    BuildContext context, {
    required int position,
    required Widget icon,
    required String title,
    required Widget Function() builder,
  }) =>
      ListTile(
        selected: position == _currentItem,
        leading: icon,
        title: Text(title),
        onTap: () => setState(() {
          _currentItem = position;
        }),
      );
}
