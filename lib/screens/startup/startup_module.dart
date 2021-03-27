import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/daos.dart';
import 'package:kres_requests2/data/models.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
import 'package:kres_requests2/data/validators.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/screens/editor/document_module.dart';
import 'package:kres_requests2/screens/settings/settings_module.dart';
import 'package:kres_requests2/screens/startup/startup_screen.dart';

/// Startup screen module
class StartupModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        // Employee-related binds
        Bind.lazySingleton<Dao<Employee, EmployeeEntity>>(
          (i) => EmployeeDao(i(), i()),
        ),
        Bind.factory<Repository<Employee>>((i) => EmployeeRepository(i())),
        Bind.factory<StreamedRepositoryController<Employee>>(
          (i) => StreamedRepositoryController(
              RepositoryController(EmployeePersistedBuilder(), i())),
        ),
        Bind.factory<MappedValidator<Employee>>((i) => EmployeeValidator()),
        // Position-related binds
        Bind.lazySingleton<Dao<Position, PositionEntity>>(
            (i) => PositionDao(i())),
        Bind.factory<Repository<Position>>(
            (i) => PersistedStorageRepository<Position, PositionEntity>(i())),
        Bind.factory<StreamedRepositoryController<Position>>(
          (i) => StreamedRepositoryController(
              RepositoryController(PositionPersistedBuilder(), i())),
        ),
        Bind.factory<MappedValidator<Position>>((i) => PositionValidator()),
        // Request type related binds
        Bind.lazySingleton<Dao<RequestType, RequestTypeEntity>>(
            (i) => RequestTypeDao(i())),
        Bind.factory<Repository<RequestType>>((i) =>
            PersistedStorageRepository<RequestType, RequestTypeEntity>(i())),
        Bind.factory<StreamedRepositoryController<RequestType>>(
          (i) => StreamedRepositoryController(
              RepositoryController(RequestTypePersistedBuilder(), i())),
        ),
        Bind.factory<MappedValidator<RequestType>>(
            (i) => RequestTypeValidator()),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => StartupScreen()),
    ModuleRoute('/settings', module: SettingsModule()),
    ModuleRoute('/document', module: DocumentModule()),
  ];
}
