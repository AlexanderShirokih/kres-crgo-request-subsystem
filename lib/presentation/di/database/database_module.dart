import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/daos.dart';
import 'package:kres_requests2/data/datasource/app_database.dart';
import 'package:kres_requests2/domain/service/database_exporter.dart';
import 'package:kres_requests2/domain/usecases/storage/import_database_data.dart';

class DatabaseModule extends Module {
  @override
  List<Bind> get binds => [
        Bind.factory(
          (i) => DatabaseExporter([
            i<RequestTypeDao>(),
            i<MegaBillingMatchingDao>(),
            i<PositionDao>(),
            i<EmployeeDao>(),
          ]),
          export: true,
        ),
        Bind.factory(
          (i) => DatabaseImporter(i<AppDatabase>()),
          export: true,
        ),
      ];
}
