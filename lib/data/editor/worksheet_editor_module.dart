import 'package:kres_requests2/data/editor/request_module.dart';
import 'package:kres_requests2/models/document.dart';

/// DI Module that contains submodules for worksheet editor
class WorksheetEditorModule {
  final RequestModule requestModule;
  final Document targetDocument;

  const WorksheetEditorModule({
    required this.requestModule,
    required this.targetDocument,
  });
}
