import 'dart:io';

import 'package:kres_requests2/domain/repository/settings_repository.dart';

/// Gets current working directory. If directory no more exists it will be
/// removed from the repository
class GetLastWorkingDirectory {
  final SettingsRepository _settingsRepository;

  GetLastWorkingDirectory(this._settingsRepository);

  Future<String?> call() async {
    final lastDirectory = await _settingsRepository.lastWorkingDirectory;

    if (lastDirectory == null) {
      return null;
    }

    final isExists = await Directory(lastDirectory).exists();

    if (!isExists) {
      await _settingsRepository.setLastUsedDirectory(null);
      return null;
    }

    return lastDirectory;
  }
}

/// Updates the current working directory
class UpdateLastWorkingDirectory {
  final SettingsRepository _settingsRepository;

  UpdateLastWorkingDirectory(this._settingsRepository);

  Future<void> call(String? path) async {
    if (path != null) {
      final dir = File(path).parent;
      await _settingsRepository.setLastUsedDirectory(dir.absolute.path);
    } else {
      await _settingsRepository.setLastUsedDirectory(null);
    }
  }
}
