import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/daos.dart';
import 'package:kres_requests2/data/editor/json_document_saver.dart';
import 'package:kres_requests2/data/editor/mega_billing_decoding_pipeline.dart';
import 'package:kres_requests2/data/java/java_process_executor.dart';
import 'package:kres_requests2/data/models.dart';
import 'package:kres_requests2/data/models/mega_billing_matching.dart';
import 'package:kres_requests2/data/models/recent_document_info.dart';
import 'package:kres_requests2/data/repository/storage_repository.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/editor/decoding_pipeline.dart';
import 'package:kres_requests2/domain/editor/document_filter.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models/mega_billing_matching.dart';
import 'package:kres_requests2/domain/process_executor.dart';
import 'package:kres_requests2/domain/repository/mega_billing_matching_repository.dart';
import 'package:kres_requests2/domain/repository/recent_documents_repository.dart';
import 'package:kres_requests2/domain/repository/settings_repository.dart';
import 'package:kres_requests2/domain/request_processor.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:kres_requests2/domain/service/export_file_chooser.dart';
import 'package:kres_requests2/domain/usecases/storage/update_last_working_directory.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/presentation/editor/document_manager_module.dart';
import 'package:kres_requests2/presentation/settings/settings_module.dart';
import 'package:kres_requests2/presentation/startup/startup_screen.dart';

/// Startup screen module
class StartupModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.factory<GetLastWorkingDirectory>(
          (i) => GetLastWorkingDirectory(i<SettingsRepository>()),
        ),
        Bind.factory<UpdateLastWorkingDirectory>(
          (i) => UpdateLastWorkingDirectory(i<SettingsRepository>()),
        ),
        Bind.factory<ProcessExecutor>(
          (i) => JavaProcessExecutor(
            settingsRepository: i(),
            javaProcessHome: Directory('requests/lib'),
          ),
        ),
        Bind.factory<DecodingPipeline>(
          (i) => MegaBillingDecodingPipeline(
            i<MegaBillingMatchingRepository>(),
          ),
        ),
        Bind.singleton<DocumentFilter>((i) => DocumentFilter()),
        Bind.instance<DocumentSaver>(
          const JsonDocumentSaver(saveLegacyInfo: true),
        ),
        Bind.factory<ExportFileChooser>((i) => ExportFileChooserImpl()),
        Bind.factory<AbstractRequestProcessor>(
          (i) => MegaBillingRequestProcessorImpl(
            i<ProcessExecutor>(),
            i<DecodingPipeline>(),
            i<DocumentSaver>(),
          ),
        ),
        // Employee-related binds
        Bind.lazySingleton<Dao<Employee, EmployeeEntity>>(
          (i) => EmployeeDao(i(), i()),
        ),
        Bind.factory<Repository<Employee>>((i) => EmployeeRepository(i())),
        Bind.factory<StreamedRepositoryController<Employee>>(
          (i) => StreamedRepositoryController(
              RepositoryController(const EmployeePersistedBuilder(), i())),
        ),
        Bind.factory<MappedValidator<Employee>>((i) => EmployeeValidator()),
        // Position-related binds
        Bind.lazySingleton<Dao<Position, PositionEntity>>(
            (i) => PositionDao(i())),
        Bind.factory<Repository<Position>>(
            (i) => PersistedStorageRepository<Position, PositionEntity>(i())),
        Bind.factory<StreamedRepositoryController<Position>>(
          (i) => StreamedRepositoryController(
              RepositoryController(const PositionPersistedBuilder(), i())),
        ),
        Bind.factory<MappedValidator<Position>>((i) => PositionValidator()),
        // Request type related binds
        Bind.lazySingleton<Dao<RequestType, RequestTypeEntity>>(
            (i) => RequestTypeDao(i())),
        Bind.factory<Repository<RequestType>>((i) =>
            PersistedStorageRepository<RequestType, RequestTypeEntity>(i())),
        Bind.factory<StreamedRepositoryController<RequestType>>(
          (i) => StreamedRepositoryController(
              RepositoryController(const RequestTypePersistedBuilder(), i())),
        ),
        Bind.factory<MappedValidator<RequestType>>(
            (i) => RequestTypeValidator()),
        Bind.lazySingleton<RecentDocumentsDao>((i) => RecentDocumentsDao(i())),
        // Recent documents related binds
        Bind.factory<Repository<RecentDocumentInfo>>(
            (i) => RecentDocumentsRepository(i())),
        Bind.lazySingleton<StreamedRepositoryController<RecentDocumentInfo>>(
          (i) => StreamedRepositoryController(
              RepositoryController(const RecentDocumentBuilder(), i())),
        ),
        // Mega-billing-related binds
        Bind.lazySingleton<Dao<MegaBillingMatching, MegaBillingMatchingEntity>>(
          (i) => MegaBillingMatchingDao(i(), i()),
        ),
        Bind.factory<Repository<MegaBillingMatching>>(
            (i) => MegaBillingMatchingRepository(i())),
        Bind.factory<StreamedRepositoryController<MegaBillingMatching>>(
          (i) => StreamedRepositoryController(
            RepositoryController(
                const MegaBillingMatchingPersistedBuilder(), i()),
          ),
        ),
        Bind.factory<MappedValidator<MegaBillingMatching>>(
          (i) => MegaBillingMatchValidator(),
        ),
        Bind.singleton<DocumentManager>(
          (i) => DocumentManager(
            i<ExportFileChooser>(),
            i<DocumentFilter>(),
            i<DocumentSaver>(),
            i<StreamedRepositoryController<RecentDocumentInfo>>(),
          ),
        ),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute('/', child: (_, __) => const StartupScreen()),
    ModuleRoute('/settings', module: SettingsModule()),
    ModuleRoute('/document', module: DocumentManagerModule()),
  ];
}
