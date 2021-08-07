import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/daos.dart';
import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/domain/service/database_exporter.dart';
import 'package:kres_requests2/domain/usecases/storage/import_database_data.dart';
import 'package:kres_requests2/presentation/settings/settings_screen.dart';

/// The settings module
class SettingsModule extends Module {

  @override
  List<Bind<Object>> get binds => [
        Bind.factory(
          (i) => DatabaseExporter([
            i<RequestTypeDao>(),
            i<PositionDao>(),
            i<EmployeeDao>(),
          ]),
        ),
        Bind.factory(
          (i) => DatabaseImporter(i<AppDatabase>()),
        ),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => const SettingsScreen()),
  ];
}
