import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/screens/preview/document_preview_screen.dart';

/// Module that contains pages to work with document preview and exporting
class PreviewModule extends Module {
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
