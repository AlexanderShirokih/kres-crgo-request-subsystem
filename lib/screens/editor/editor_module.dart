import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/data/editor/json_document_saver.dart';
import 'package:kres_requests2/domain/editor/document_filter.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/service/document_service.dart';
import 'package:kres_requests2/domain/service/request_service.dart';
import 'package:kres_requests2/domain/service/worksheet_service.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/screens/common.dart';
import 'package:kres_requests2/screens/preview/preview_module.dart';

import 'document_editor_screen.dart';

/// Module that contains pages to work with currently opened document
class EditorModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        // Request entity related binds
        Bind.factory<MappedValidator<Request>>((i) => RequestValidator()),
        Bind.instance<DocumentSaver>(JsonDocumentSaver(saveLegacyInfo: false)),
        Bind.factory<RequestService>(
          (i) => RequestService(i(), i(), i.args!.data as Document),
        ),
        Bind.factory<WorksheetService>(
          (i) => WorksheetService(i.args!.data as Document, i()),
        ),
        Bind.factory(
          (i) {
            final document = i.args!.data as Document;
            return DocumentService(
              document,
              i(),
              DocumentFilter(document),
              showSaveDialog,
            );
          },
        ),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (_, args) => BlocProvider(
        create: (_) => DocumentMasterBloc(Modular.get(), Modular.to),
        child: DocumentEditorScreen(),
      ),
    ),
    ModuleRoute(
      '/preview',
      module: PreviewModule(),
    ),
  ];
}
