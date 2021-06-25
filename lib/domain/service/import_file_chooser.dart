import 'package:file_selector/file_selector.dart';

import 'import/document_import_service.dart';

/// Interface for picking file
abstract class ImportFileChooser {
  /// Shows file picker to choose the file
  Future<String?> pickFile();

  factory ImportFileChooser.forType(ImportType type) {
    switch (type) {
      case ImportType.excelRequests:
        return _FileChooserImpl(
          'Файлы Excel 97-2003',
          ['xls'],
        );
      case ImportType.excelCounters:
        return _FileChooserImpl(
          'Файлы Excel 2007-365',
          ['xlsx'],
        );
      case ImportType.native:
        return _FileChooserImpl(
          'Документ заявок',
          ['json'],
        );
    }
  }
}

class _FileChooserImpl implements ImportFileChooser {
  final String fileLabel;
  final List<String> extensions;

  _FileChooserImpl(this.fileLabel, this.extensions);

  Future<String?> _getLastUsedDirectory() async {
    // TODO: Implement method
    return null;
  }

  @override
  Future<String?> pickFile() async {
    return await openFile(
      initialDirectory: await _getLastUsedDirectory(),
      confirmButtonText: 'Открыть',
      acceptedTypeGroups: [
        XTypeGroup(label: fileLabel, extensions: extensions)
      ],
    ).then((file) => file?.path);
  }
}
