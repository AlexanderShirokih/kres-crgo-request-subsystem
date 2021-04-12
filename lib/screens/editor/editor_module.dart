import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/editor/request_entity.dart';
import 'package:kres_requests2/data/repository/request_repository.dart';
import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/data/validators/request_validator.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/repository/repository.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/models/request_entity.dart';

import 'document_editor_screen.dart';

/// Module that contains pages to work with currently opened document
class EditorModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        // Request entity related binds
        Bind.factory<Repository<RequestEntity>>((i) => PageRequestRepository()),

        Bind.factory<StreamedRepositoryController<RequestEntity>>(
          (i) => StreamedRepositoryController(
            RepositoryController(StubbedRequestEntityBuilder(), i()),
          ),
        ),

        Bind.factory<MappedValidator<RequestEntity>>((i) => RequestValidator()),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (_, args) => DocumentEditorScreen(document: args.data as Document),
    ),
  ];
}
