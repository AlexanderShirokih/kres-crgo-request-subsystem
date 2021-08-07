import 'dart:io';

import 'package:kres_requests2/domain/usecases/usecases.dart';
import 'package:file_selector/file_selector.dart';

abstract class DirectoryChooser {
  /// Open directory choose dialog
  Future<String?> chooseDirectory();
}

class DirectoryChooserImpl implements DirectoryChooser {
  final AsyncUseCase<String> getCurrentDirectory;

  DirectoryChooserImpl(this.getCurrentDirectory);

  @override
  Future<String?> chooseDirectory() async {
    final current = await getCurrentDirectory();

    final isDir = await FileSystemEntity.isDirectory(current);

    return await getDirectoryPath(
      initialDirectory: isDir ? current : File(current).parent.absolute.path,
      confirmButtonText: 'Выбрать',
    );
  }
}
