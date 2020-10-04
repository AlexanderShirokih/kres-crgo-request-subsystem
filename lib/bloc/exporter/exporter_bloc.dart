import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

      final file = await fileChooser();
      if (file == null) {
        yield ExporterClosingState(isCompleted: false);
        return;
      }

      final tempFile = await _saveToTempFile();
      final isOk = await _runExporter(file, tempFile.path);
      await tempFile.delete();

      if (isOk) {
        yield ExporterClosingState(isCompleted: true);
      } else {
        yield ExporterErrorState();
      }

      return;
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

  Future<bool> _runExporter(String exportDestination, String sourceFile) =>
      Process.run(exporterExecutable, ['-pdf', exportDestination, sourceFile])
          .then((result) => result.exitCode == 0);
}
