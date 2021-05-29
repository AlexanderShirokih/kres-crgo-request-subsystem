import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/editor/document_master_bloc.dart';
import 'package:kres_requests2/data/editor/json_document_saver.dart';
import 'package:kres_requests2/domain/editor/document_saver.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/domain/models/request_entity.dart';
import 'package:kres_requests2/domain/validators.dart';
import 'package:kres_requests2/screens/common.dart';
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
      child: (_, args) => BlocProvider(
        create: (_) => DocumentMasterBloc(
          args.data as Document,
          documentSaver: Modular.get(),
          savePathChooser: showSaveDialog,
        ),
        child: DocumentEditorScreen(),
      ),
    ),
    ModuleRoute(
      '/preview',
      module: PreviewModule(),
    ),
  ];
}
