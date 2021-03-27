import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/models/document.dart';
import 'package:kres_requests2/repo/worksheet_importer_repository.dart';
import 'package:kres_requests2/screens/editor/document_editor_screen.dart';
import 'package:kres_requests2/screens/importer/native_import_screen.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';

/// Module that contains all pages and submodules to work with documents
class DocumentModule extends Module {
  @override
  List<Bind<Object>> get binds => [];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/edit',
      child: (_, args) => DocumentEditorScreen(document: args.data as Document),
    ),
    ChildRoute(
      '/open',
      child: (_, args) => NativeImporterScreen(
        importerRepository: NativeImporterRepository(),
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
