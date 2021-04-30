import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/preview/preview_bloc.dart';
import 'package:kres_requests2/domain/exchange/requests_export_service.dart';
import 'package:kres_requests2/domain/models/document.dart';
import 'package:kres_requests2/screens/preview/document_preview_screen.dart';

/// Module that contains pages to work with document preview and exporting
class PreviewModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.factory((i) => RequestsExportService(i())),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (_, args) => BlocProvider(
        create: (_) => PreviewBloc(args.data as Document),
        child: DocumentPreviewScreen(),
      ),
    ),
  ];
}
