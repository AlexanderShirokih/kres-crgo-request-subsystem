import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/service/file_picker_service.dart';
import 'package:kres_requests2/domain/service/import/counters_import_service.dart';
import 'package:kres_requests2/domain/service/import/document_import_service.dart';
import 'package:kres_requests2/domain/service/import/megabilling_import_service.dart';
import 'package:kres_requests2/domain/service/import/native_import_service.dart';
import 'package:kres_requests2/domain/service/import_file_chooser.dart';
import 'package:kres_requests2/presentation/bloc/importer/importer_bloc.dart';
import 'package:kres_requests2/presentation/editor/editor_module.dart';
import 'package:kres_requests2/presentation/importer/counters_importer_screen.dart';
import 'package:kres_requests2/presentation/importer/dialogs/table_chooser_dialog.dart';
import 'package:kres_requests2/presentation/importer/dialogs/worksheets_chooser_dialog.dart';
import 'package:kres_requests2/presentation/importer/native_import_screen.dart';
import 'package:kres_requests2/presentation/importer/requests_importer_screen.dart';

/// Module that contains all submodules to work with documents.
/// Provides routes to open, import or edit documents.
class DocumentManagerModule extends Module {
  @override
  final List<ModularRoute> routes = [
    ModuleRoute('/edit', module: EditorModule()),
    ChildRoute(
      '/open',
      child: (_, args) {
        final Map<String, dynamic> data = args.data ?? {};

        return BlocProvider(
          create: (context) => ImporterBloc(
            navigator: Modular.to,
            documentManager: Modular.get(),
            importService: NativeImporterService(
              Modular.get(),
              tableChooser: ((args.queryParams['pickPages'] == 'true'))
                  ? (tables) => showDialog<List<Worksheet>>(
                        context: context,
                        builder: (_) => WorksheetsChooserDialog(tables),
                      ).then((worksheets) => worksheets ?? <Worksheet>[])
                  : null,
            ),
            pickerService: FilePickerServiceImpl(
              ImportFileChooser.forType(ImportType.native),
            ),
          )..add(ImportEvent(filePath: data['filePath'])),
          child: const NativeImporterScreen(),
        );
      },
    ),
    ChildRoute(
      '/import/requests',
      child: (_, args) {
        return BlocProvider(
          create: (_) => ImporterBloc(
            navigator: Modular.to,
            documentManager: Modular.get(),
            importService: MegaBillingImportService(Modular.get()),
            pickerService: FilePickerServiceImpl(
              ImportFileChooser.forType(ImportType.excelRequests),
            ),
          ),
          child: const RequestsImporterScreen(),
        );
      },
    ),
    ChildRoute(
      'import/counters',
      child: (_, args) {
        return BlocProvider(
          create: (context) => ImporterBloc(
            navigator: Modular.to,
            documentManager: Modular.get(),
            importService: CountersImportService(
              tableChooser: (tables) => showDialog<String>(
                context: context,
                builder: (_) => TableChooserDialog(tables),
              ),
            ),
            pickerService: FilePickerServiceImpl(
              ImportFileChooser.forType(ImportType.excelCounters),
            ),
          ),
          child: const CountersImportScreen(),
        );
      },
    ),
  ];
}
