import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/data/editor/json_document_saver.dart';
import 'package:kres_requests2/data/request_processor.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/repo/requests_repository.dart';
import 'package:kres_requests2/screens/preview/document_preview_screen.dart';

/// Module that contains pages to work with document preview and exporting
class PreviewModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.factory((i) => RequestsRepository(
              RequestProcessorImpl(
                i(),
                JsonDocumentSaver(saveLegacyInfo: false),
              ),
            )),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (_, args) => DocumentPreviewScreen(
        document: args.data as Document,
      ),
    ),
  ];
}
