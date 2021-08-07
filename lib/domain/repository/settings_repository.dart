import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  Future<String?> get javaPath;

  Future<String?> get lastWorkingDirectory;

  Future<String?> get lastUsedPrinter;

  Future<void> setJavaPath(String? file);

  Future<void> setLastUsedDirectory(String? directory);

  Future<void> setLastUsedPrinter(String? printer);

  const SettingsRepository();

  factory SettingsRepository.fromPreferences() => _PrefsSettingsRepository._();
}

class _PrefsSettingsRepository extends SettingsRepository {
  static const _kLastUsedPrinter = 'last_printer';
  static const _kJavaPath = 'java_home';
  static const _kLastUsedDirectory = 'last_used_directory';

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
  Future<String?> get javaPath =>
      _prefs.then((prefs) => prefs.getString(_kJavaPath));

  @override
  Future<String?> get lastWorkingDirectory =>
      _prefs.then((prefs) => prefs.getString(_kLastUsedDirectory));

  @override
  Future<String?> get lastUsedPrinter =>
      _prefs.then((prefs) => prefs.getString(_kLastUsedPrinter));

  @override
  Future<void> setJavaPath(String? path) async {
    final prefs = await _prefs;

    if (path == null) {
      await prefs.remove(_kJavaPath);
    } else {
      await prefs.setString(_kJavaPath, path);
    }
  }

  @override
  Future<void> setLastUsedDirectory(String? directory) async {
    final prefs = await _prefs;

    if (directory == null) {
      await prefs.remove(_kLastUsedDirectory);
    } else {
      await prefs.setString(_kLastUsedDirectory, directory);
    }
  }

  @override
  Future<void> setLastUsedPrinter(String? printer) async {
    final prefs = await _prefs;

    if (printer == null) {
      await prefs.remove(_kLastUsedPrinter);
    } else {
      await prefs.setString(_kLastUsedPrinter, printer);
    }
  }
}
