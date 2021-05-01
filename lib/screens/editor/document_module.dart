import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/domain/exchange/counters_import_service.dart';
import 'package:kres_requests2/domain/exchange/file_chooser.dart';
import 'package:kres_requests2/domain/exchange/megabilling_import_service.dart';
import 'package:kres_requests2/domain/exchange/native_import_service.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/screens/editor/editor_module.dart';
import 'package:kres_requests2/screens/importer/counters_importer_screen.dart';
import 'package:kres_requests2/screens/importer/dialogs/table_chooser_dialog.dart';
import 'package:kres_requests2/screens/importer/dialogs/worksheets_chooser_dialog.dart';
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
            startWithPicker: true,
            filePath: data['filePath'],
            targetDocument: data['document'],
            importerService: NativeImporterService(
              Modular.get(),
              tableChooser: ((args.queryParams['pickPages'] == 'true'))
                  ? (tables) => showDialog<List<Worksheet>>(
                        context: context,
                        builder: (_) => WorksheetsChooserDialog(tables),
                      ).then((worksheets) => worksheets ?? <Worksheet>[])
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
            importerService: CountersImportService(
              tableChooser: (tables) => showDialog<String>(
                context: context,
                builder: (_) => TableChooserDialog(tables),
              ),
            ),
            fileChooser: FileChooser.forType(
              FilePickerType.excelCounters,
              data['workingDirectory'],
            ),
          ),
          child: CountersImportScreen(),
        );
      },
    ),
  ];
}
