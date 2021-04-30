import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/domain/counters_importer.dart';
import 'package:kres_requests2/domain/exchange/document_importer_service.dart';
import 'package:kres_requests2/domain/exchange/file_chooser.dart';
import 'package:kres_requests2/domain/exchange/megabilling_import_service.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/screens/editor/editor_module.dart';
import 'package:kres_requests2/screens/importer/counters_importer_screen.dart';
import 'package:kres_requests2/screens/importer/native_import_screen.dart';
import 'package:kres_requests2/screens/importer/requests_importer_screen.dart';

/// Module that contains all pages and submodules to work with documents
class DocumentModule extends Module {
  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/edit', module: EditorModule()),
    ChildRoute(
      '/open',
      child: (_, args) {
        final Map<String, dynamic> data = args.data ?? {};
        return BlocProvider(
          create: (context) => ImporterBloc(
            filePath: data['filePath'],
            targetDocument: data['document'],
            importerService: NativeImporterService(
              Modular.get(),
              tableChooser: (args.params['pickPages'] ?? false)
                  ? (tables) async {
                      final worksheets = await showDialog<List<Worksheet>>(
                        context: context,
                        builder: (_) => SelectWorksheetsDialog(tables),
                      );
                      return worksheets!;
                    }
                  : null,
            ),
            fileChooser: FileChooser.forType(
              FilePickerType.native,
              data['workingDirectory'],
            ),
          ),
          child: NativeImporterScreen(),
        );
      },
    ),
    ChildRoute(
      '/import/requests',
      child: (_, args) {
        final Map<String, dynamic> data = args.data ?? {};
        return BlocProvider(
          create: (_) => ImporterBloc(
            targetDocument: data['document'],
            importerService: MegaBillingImportService(Modular.get()),
            fileChooser: FileChooser.forType(
              FilePickerType.excelRequests,
              data['workingDirectory'],
            ),
          ),
          child: RequestsImporterScreen(),
        );
      },
    ),
    ChildRoute(
      'import/counters',
      child: (_, args) {
        final Map<String, dynamic> data = args.data ?? {};
        return BlocProvider(
          create: (context) => ImporterBloc(
            targetDocument: data['document'],
            importerService: CountersImporterService(
              importer: CountersImporter(),
              tableChooser: (tables) => showDialog<String>(
                context: context,
                builder: (_) => TableSelectionDialog(tables),
              ),
            ),
            fileChooser: FileChooser.forType(
              FilePickerType.excelCounters,
              data['workingDirectory'],
            ),
          ),
          child: CountersImporterScreen(),
        );
      },
    ),
  ];
}
