import 'dart:io';

import 'package:kres_requests2/domain/service/import_file_chooser.dart';

/// Service used to pick files from the storage
abstract class FilePicker {
  /// Picks a file from the storage.
  /// If [desiredPath] is present and exists, the [desiredPath] will be return
  Future<String?> chooseSourcePath(File? desiredPath);
}

/// Service used to pick files from the storage
class FilePickerServiceImpl implements FilePicker {
  /// Function for picking files from the storage
  final ImportFileChooser _fileChooser;

  FilePickerServiceImpl(this._fileChooser);

  Future<String?> chooseSourcePath(File? desiredPath) async {
    if (desiredPath != null && await desiredPath.exists()) {
      return desiredPath.absolute.path;
    }
    return await _fileChooser.pickFile();
  }
}
