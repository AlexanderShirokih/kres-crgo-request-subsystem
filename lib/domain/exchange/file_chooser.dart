import 'package:file_selector/file_selector.dart';

/// Defines kinds of default file pickers dialogs
enum FilePickerType {
  excelRequests,
  excelCounters,
  native,
}

/// Interface for picking file
abstract class FileChooser {
  /// Shows file picker to choose the file
  Future<String?> pickFile();

  factory FileChooser.forType(FilePickerType type, String? workingDirectory) {
    switch (type) {
      case FilePickerType.excelRequests:
        return _FileChooserImpl(
          workingDirectory,
          'Файлы Excel 97-2003',
          ['xls'],
        );
      case FilePickerType.excelCounters:
        return _FileChooserImpl(
          workingDirectory,
          'Файлы Excel 2007-365',
          ['xlsx'],
        );
      case FilePickerType.native:
        return _FileChooserImpl(
          workingDirectory,
          'Документ заявок',
          ['json'],
        );
    }
  }
}

class _FileChooserImpl implements FileChooser {
  final String? workingDirectory;
  final String fileLabel;
  final List<String> extensions;

  _FileChooserImpl(this.workingDirectory, this.fileLabel, this.extensions);

  Future<String?> _getLastUsedDirectory() async {
    // TODO: Implement method
    return null;
  }

  @override
  Future<String?> pickFile() async {
    return await openFile(
      initialDirectory: workingDirectory ?? await _getLastUsedDirectory(),
      confirmButtonText: 'Открыть',
      acceptedTypeGroups: [
        XTypeGroup(label: fileLabel, extensions: extensions)
      ],
    ).then((file) => file?.path);
  }
}
