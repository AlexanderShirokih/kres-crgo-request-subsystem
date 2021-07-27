import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/presentation/settings/settings_screen.dart';

/// The settings module
class SettingsModule extends Module {
  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => const SettingsScreen()),
  ];
}
