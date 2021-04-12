import 'dart:io';

import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';
import 'package:kres_requests2/screens/editor/editor_module.dart';
import 'package:kres_requests2/screens/importer/native_import_screen.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';

/// Module that contains all pages and submodules to work with documents
class DocumentModule extends Module {
  @override
  List<Bind<Object>> get binds => [];

  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/edit', module: EditorModule()),
    ChildRoute(
      '/open',
      child: (_, args) => NativeImporterScreen(
        importerRepository: NativeImporterRepository(Modular.get()),
        openPath: args.data as File?,
      ),
    ),
    ChildRoute(
      '/import/requests',
      child: (ctx, args) => RequestsImporterScreen.fromContext(
        context: ctx,
        targetDocument: args.data as Document,
      ),
    ),
  ];
}
