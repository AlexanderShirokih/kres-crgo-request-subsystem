import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<String?> get javaPath;

  Future<String?> get lastWorkingDirectory;

  Future<String?> get lastUsedPrinter;

  Future<String?> get databasePath;

  Future<void> setJavaPath(String? file);

  Future<void> setLastUsedDirectory(String? directory);

  Future<void> setLastUsedPrinter(String? printer);

  Future<void> setDatabasePath(String? databasePath);

  const SettingsRepository();

  factory SettingsRepository.fromPreferences() => _PrefsSettingsRepository._();
}

class _PrefsSettingsRepository extends SettingsRepository {
  static const _kLastUsedPrinter = 'last_printer';
  static const _kJavaPath = 'java_home';
  static const _kLastUsedDirectory = 'last_used_directory';
  static const _kDbPath = 'database_path';

  Completer<SharedPreferences>? _prefsCompleter;

  _PrefsSettingsRepository._();

  Future<SharedPreferences> get _prefs {
    if (_prefsCompleter == null) {
      _prefsCompleter = Completer();
      _prefsCompleter!.complete(SharedPreferences.getInstance());
    }
    return _prefsCompleter!.future;
  }

  @override
  Future<String?> get javaPath => _getString(_kJavaPath);

  @override
  Future<String?> get databasePath => _getString(_kDbPath);

  @override
  Future<String?> get lastWorkingDirectory => _getString(_kLastUsedDirectory);

  @override
  Future<String?> get lastUsedPrinter => _getString(_kLastUsedPrinter);

  @override
  Future<void> setJavaPath(String? path) => _setString(_kJavaPath, path);

  @override
  Future<void> setDatabasePath(String? dbPath) => _setString(_kDbPath, dbPath);

  @override
  Future<void> setLastUsedDirectory(String? directory) =>
      _setString(_kLastUsedDirectory, directory);

  @override
  Future<void> setLastUsedPrinter(String? printer) =>
      _setString(_kLastUsedPrinter, printer);

  Future<String?> _getString(String key) =>
      _prefs.then((prefs) => prefs.getString(key));

  Future<void> _setString(String key, String? value) async {
    final prefs = await _prefs;

    if (value == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, value);
    }
  }
}
