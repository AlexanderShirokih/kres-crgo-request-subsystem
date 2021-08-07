import 'package:file_selector/file_selector.dart';
import 'package:kres_requests2/domain/usecases/storage/update_last_working_directory.dart';
import 'package:kres_requests2/domain/usecases/usecases.dart';

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
        return FileChooserImpl(
          label: 'Файлы Excel 97-2003',
          extensions: ['xls'],
          getWorkingDirectory: getWorkingDirectory,
          updateWorkingDirectory: updateWorkingDirectory,
        );
      case ImportType.excelCounters:
        return FileChooserImpl(
          label: 'Файлы Excel 2007-365',
          extensions: ['xlsx'],
          getWorkingDirectory: getWorkingDirectory,
          updateWorkingDirectory: updateWorkingDirectory,
        );
      case ImportType.native:
        return FileChooserImpl(
          label: 'Документ заявок',
          extensions: ['json'],
          getWorkingDirectory: getWorkingDirectory,
          updateWorkingDirectory: updateWorkingDirectory,
        );
    }
  }
}

class FileChooserImpl implements ImportFileChooser {
  final String label;
  final List<String> extensions;
  final AsyncUseCase<String> getWorkingDirectory;
  final UpdateLastWorkingDirectory? updateWorkingDirectory;

  FileChooserImpl({
    required this.label,
    required this.extensions,
    required this.getWorkingDirectory,
    this.updateWorkingDirectory,
  });

  @override
  Future<String?> pickFile() async {
    return await openFile(
      initialDirectory: await getWorkingDirectory(),
      confirmButtonText: 'Открыть',
      acceptedTypeGroups: [XTypeGroup(label: label, extensions: extensions)],
    ).then((file) async {
      final path = file?.path;

      if (updateWorkingDirectory != null) {
        await updateWorkingDirectory!(path);
      }

      return path;
    });
  }
}
