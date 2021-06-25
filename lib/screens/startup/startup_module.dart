import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/daos.dart';
import 'package:kres_requests2/data/editor/json_document_saver.dart';
import 'package:kres_requests2/data/java/java_process_executor.dart';
import 'package:kres_requests2/data/models.dart';
import 'package:kres_requests2/data/models/recent_document_info.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/process_executor.dart';
import 'package:kres_requests2/domain/repository/recent_documents_repository.dart';
import 'package:kres_requests2/domain/request_processor.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/screens/editor/document_module.dart';
import 'package:kres_requests2/screens/settings/settings_module.dart';
import 'package:kres_requests2/screens/startup/startup_screen.dart';

/// Startup screen module
class StartupModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.factory<ProcessExecutor>(
          (i) => JavaProcessExecutor(
            settingsRepository: i(),
            javaProcessHome: Directory('requests/lib'),
          ),
        ),
        Bind.factory<AbstractRequestProcessor>(
          (i) => RequestProcessorImpl(
            i(),
            JsonDocumentSaver(saveLegacyInfo: false),
          ),
        ),
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
        Bind.lazySingleton<RecentDocumentsDao>((i) => RecentDocumentsDao(i())),
        // Recent documents related binds
        Bind.factory<Repository<RecentDocumentInfo>>(
            (i) => RecentDocumentsRepository(i())),
        Bind.lazySingleton<StreamedRepositoryController<RecentDocumentInfo>>(
          (i) => StreamedRepositoryController(
              RepositoryController(RecentDocumentBuilder(), i())),
        ),
        Bind.singleton<DocumentManager>((i) => DocumentManager()),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => StartupScreen()),
    ModuleRoute('/settings', module: SettingsModule()),
    ModuleRoute('/document', module: DocumentModule()),
  ];
}
