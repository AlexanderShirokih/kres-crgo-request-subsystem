import 'package:file_selector/file_selector.dart';
import 'package:kres_requests2/domain/usecases/storage/update_last_working_directory.dart';

import 'import/document_import_service.dart';

/// Interface for picking file
abstract class ImportFileChooser {
  /// Shows file picker to choose the file
  Future<String?> pickFile();

  factory ImportFileChooser.forType(
    ImportType type,
    GetLastWorkingDirectory getWorkingDirectory,
    UpdateLastWorkingDirectory updateWorkingDirectory,
  ) {
    switch (type) {
      case ImportType.excelRequests:
        return _FileChooserImpl(
          'Файлы Excel 97-2003',
          ['xls'],
          getWorkingDirectory,
          updateWorkingDirectory,
        );
      case ImportType.excelCounters:
        return _FileChooserImpl(
          'Файлы Excel 2007-365',
          ['xlsx'],
          getWorkingDirectory,
          updateWorkingDirectory,
        );
      case ImportType.native:
        return _FileChooserImpl(
          'Документ заявок',
          ['json'],
          getWorkingDirectory,
          updateWorkingDirectory,
        );
    }
  }
}

class _FileChooserImpl implements ImportFileChooser {
  final String fileLabel;
  final List<String> extensions;
  final GetLastWorkingDirectory getWorkingDirectory;
  final UpdateLastWorkingDirectory updateWorkingDirectory;

  _FileChooserImpl(
    this.fileLabel,
    this.extensions,
    this.getWorkingDirectory,
    this.updateWorkingDirectory,
  );

  @override
  Future<String?> pickFile() async {
    return await openFile(
      initialDirectory: await getWorkingDirectory(),
      confirmButtonText: 'Открыть',
      acceptedTypeGroups: [
        XTypeGroup(label: fileLabel, extensions: extensions)
      ],
    ).then((file) async {
      final path = file?.path;
      await updateWorkingDirectory(path);

      return path;
    });
  }
}
