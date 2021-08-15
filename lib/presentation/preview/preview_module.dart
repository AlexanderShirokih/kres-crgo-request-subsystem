import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/service/export_service.dart';
import 'package:kres_requests2/domain/service/requests_export_service.dart';
import 'package:kres_requests2/presentation/bloc/exporter/exporter_bloc.dart';
import 'package:kres_requests2/presentation/bloc/preview/preview_bloc.dart';
import 'package:kres_requests2/presentation/preview/document_preview_screen.dart';

/// Module that contains pages to work with document preview and exporting
class PreviewModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.factory((i) => RequestsExportService(i())),
        Bind.factory<ExportService>((i) => ExportService(i(), i(), i())),
        Bind.factory<ExporterBloc>(
          (i) => ExporterBloc(service: i()),
        ),
        Bind.factory<PreviewBloc>(
          (i) => PreviewBloc(i()),
        ),
      ];

  @override
  final List<ModularRoute> routes = [
    ChildRoute(
      '/',
      child: (_, args) => const DocumentPreviewScreen(),
    ),
  ];
}
