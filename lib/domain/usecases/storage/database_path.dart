import 'dart:io';

import 'package:kres_requests2/domain/repository/settings_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../usecases.dart';

const String _dbName = 'main.db';

/// Gets current database path.
class GetDatabasePath implements AsyncUseCase<String> {
  final SettingsRepository _settingsRepository;

  GetDatabasePath(this._settingsRepository);

  @override
  Future<String> call() async {
    // Get application files directory
    final defaultDirectory = await getApplicationSupportDirectory();
    final defaultPath = defaultDirectory.absolute.path;

    final currentDbPath = await _settingsRepository.databasePath;

    final directory =
        currentDbPath == null || await _isNotExistingDirectory(currentDbPath)
            ? defaultPath
            : currentDbPath;

    return join(directory, _dbName);
  }
}

/// Updates the current database path
class UpdateDatabasePath {
  final SettingsRepository _settingsRepository;

  UpdateDatabasePath(this._settingsRepository);

  Future<void> call(String? path) async {
    if (path == null) {
      await _settingsRepository.setDatabasePath(null);
      return;
    }

    final dir = Directory(path);

    if (await dir.exists()) {
      await _settingsRepository.setDatabasePath(dir.absolute.path);
    }
  }
}

Future<bool> _isNotExistingDirectory(String path) async =>
    !(await FileSystemEntity.isDirectory(path)) ||
    !(await Directory(path).exists());
