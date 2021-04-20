import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/editor/json_document_saver.dart';
import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/data/validators/request_validator.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/screens/preview/preview_module.dart';

import 'document_editor_screen.dart';

/// Module that contains pages to work with currently opened document
class EditorModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        // Request entity related binds
        Bind.factory<MappedValidator<RequestEntity>>((i) => RequestValidator()),
        Bind.instance<DocumentSaver>(JsonDocumentSaver(saveLegacyInfo: false)),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (_, args) => DocumentEditorScreen(
        document: args.data as Document,
        documentSaver: Modular.get(),
      ),
    ),
    ModuleRoute(
      '/preview',
      module: PreviewModule(),
    ),
  ];
}
