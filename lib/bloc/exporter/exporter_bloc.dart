import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:kres_requests2/data/process_result.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';

import 'package:kres_requests2/data/worksheet.dart';

part 'exporter_event.dart';

part 'exporter_state.dart';

class ExporterBloc extends Bloc<ExporterEvent, ExporterState> {
  final String exporterExecutable;
  final List<Worksheet> worksheets;
  final Future<String> Function() fileChooser;

  ExporterBloc({
    @required this.exporterExecutable,
    @required this.fileChooser,
    @required this.worksheets,
  })  : assert(exporterExecutable != null),
        assert(fileChooser != null),
        assert(worksheets != null),
        super(ExporterInitial()) {
    add(ExporterShowSaveDialogEvent());
  }

  @override
  Stream<ExporterState> mapEventToState(ExporterEvent event) async* {
    if (event is ExporterShowSaveDialogEvent) {
      if (!await _checkExporter()) {
        yield ExporterMissingState();
        return;
      }

      final filePath = await fileChooser();
      if (filePath == null) {
        yield ExporterClosingState(isCompleted: false);
        return;
      }

      final tempFile = await _saveToTempFile();

      final result = await _runExporter(filePath, tempFile.path);
      await tempFile.delete();

      if (result.hasError()) {
        yield ExporterErrorState(result.createException());
      } else {
        yield ExporterClosingState(isCompleted: true);
      }
    }
  }

  Future<bool> _checkExporter() => File(exporterExecutable).exists();

  Future<File> _saveToTempFile() async {
    final tempDir = await getTemporaryDirectory();
    final tempFile =
        File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}');

    final encoded = await Future.microtask(
      () => json.encode(worksheets.map((w) => w.toJson()).toList()),
    );

    return await tempFile.writeAsString(encoded);
  }

  Future<RequestsProcessResult> _runExporter(
          String exportDestination, String sourceFile) =>
      Process.run(File(exporterExecutable).absolute.path,
          ['-pdf', sourceFile, exportDestination]).then(
        (result) => result.exitCode == 0
            ? RequestsProcessResult.fromJson(
                jsonDecode(result.stdout), (d) => "")
            : RequestsProcessResult(
                error: 'Ошибка экспорта!\n${result.stderr}'),
      );
}
