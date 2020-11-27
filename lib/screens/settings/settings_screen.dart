import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:kres_requests2/repo/repository_module.dart';
import 'package:kres_requests2/repo/settings_repository.dart';
import 'package:kres_requests2/screens/management/positions_management_screen.dart';
import 'package:kres_requests2/screens/management/request_type_management_screen.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsRepository settingsRepository;
  final RepositoryModule repositoryModule;

  SettingsScreen({Key key, this.repositoryModule})
      : settingsRepository = repositoryModule.getSettingsRepository(),
        super(key: key);

  static Route createRoute(RepositoryModule reposModule) => MaterialPageRoute(
        builder: (_) => SettingsScreen(repositoryModule: reposModule),
      );

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Параметры'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000.0),
            child: ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                _managementItem(
                    'Сотрудники',
                    () =>
                        RequestTypesManagementScreen(widget.repositoryModule)),
                _managementItem('Должности',
                    () => PositionsManagementScreen(widget.repositoryModule)),
                _managementItem(
                    'Типы заявок',
                    () =>
                        RequestTypesManagementScreen(widget.repositoryModule)),
              ],
            ),
          ),
        ),
      );

  Widget _managementItem(String title, Widget Function() managementClass) =>
      Builder(
        builder: (context) => ListTile(
          contentPadding: EdgeInsets.all(12.0),
          leading: FaIcon(FontAwesomeIcons.cog),
          title: Text(title),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => managementClass()),
          ),
        ),
      );
}
