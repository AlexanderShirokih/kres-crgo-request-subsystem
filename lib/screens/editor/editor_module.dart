import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/data/editor/json_document_saver.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/service/document_service.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/screens/editor/document_editor_screen.dart';
import 'package:kres_requests2/screens/preview/preview_module.dart';

// Module that contains pages to work with the opened documents
class EditorModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        // Request entity related binds
        Bind.factory<MappedValidator<Request>>((i) => RequestValidator()),
        Bind.instance<DocumentSaver>(JsonDocumentSaver(saveLegacyInfo: false)),

        // TODO: Replace with factory to drop argument dependency
        // Bind.factory<RequestService>(
        //   (i) => RequestService(i(), i(), i.args!.data as Document),
        // ),
        Bind.factory<WorksheetServiceFactory>(
          (i) => WorksheetServiceFactory(i()),
        ),
        Bind.factory<DocumentServiceFactory>(
          (i) => DocumentServiceFactory(i()),
        ),
        Bind.factory((i) => DocumentMasterBloc(i(), i(), Modular.to)),
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
