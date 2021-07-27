import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/service/document_manager.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/presentation/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/presentation/editor/document_editor_screen.dart';
import 'package:kres_requests2/presentation/preview/preview_module.dart';

// Module that contains pages to work with the opened documents
class EditorModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        // Request entity related binds
        Bind.factory<MappedValidator<Request>>((i) => RequestValidator()),
        // TODO: Replace factories with a separate modules to drop argument dependency
        // Bind.factory<RequestService>(
        //   (i) => RequestService(i(), i(), i.args!.data as Document),
        // ),
        Bind.factory(
          (i) => DocumentMasterBloc(i<DocumentManager>(), Modular.to),
        ),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (_, args) {
        final params = args.queryParams;
        return DocumentEditorScreen(
          blankDocumentOnStart:
              params.containsKey("start") && params.containsValue("blank"),
        );
      },
    ),
    ModuleRoute(
      '/preview',
      module: PreviewModule(),
    ),
  ];
}
