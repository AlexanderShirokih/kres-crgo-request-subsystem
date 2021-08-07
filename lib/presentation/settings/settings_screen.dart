import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kres_requests2/presentation/settings/employees/employees_screen.dart';
import 'package:kres_requests2/presentation/settings/positions/positions_screen.dart';
import 'package:kres_requests2/presentation/settings/request_types/request_types_screen.dart';

import 'db_utils/db_utils_screen.dart';
import 'java_path_selector/java_path_selector_screen.dart';

/// The settings screen. Provides access to main app preference tables and
/// ability to configure main parameters.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

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
  int _currentItem = 0;

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavigableItem(
        icon: const Icon(Icons.work),
        title: 'Сотрудники',
        builder: () => const EmployeesScreen(),
      ),
      _NavigableItem(
        icon: const Icon(Icons.badge),
        title: 'Должности',
        builder: () => const PositionsScreen(),
      ),
      _NavigableItem(
        icon: const FaIcon(FontAwesomeIcons.wrench),
        title: 'Типы заявок',
        builder: () => const RequestTypesScreen(),
      ),
      _NavigableItem(
        icon: const FaIcon(FontAwesomeIcons.java),
        title: 'Путь к Java (JAVA_HOME)',
        builder: () => const JavaPathChooserScreen(),
      ),
      _NavigableItem(
        icon: const FaIcon(FontAwesomeIcons.database),
        title: 'База данных',
        builder: () => const DatabaseUtilsScreen(),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: Row(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340.0),
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
            child: items[_currentItem].builder(),
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
