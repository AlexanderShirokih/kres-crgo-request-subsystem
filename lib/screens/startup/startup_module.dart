import 'package:kres_requests2/app_module.dart';
import 'package:kres_requests2/data/settings/settings_module.dart';
import 'package:kres_requests2/domain/lazy.dart';

class StartupModule {
  final AppModule appModule;

  Lazy<SettingsModule> _settingsModule = Lazy();

  StartupModule(this.appModule);

  SettingsModule get settingsModule => _settingsModule.call(
        () => SettingsModule(appModule.databaseModule),
      );
}
