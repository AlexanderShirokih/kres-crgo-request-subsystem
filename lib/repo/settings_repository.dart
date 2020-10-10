import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  File get requestsProcessorExecutable;

  set requestsProcessorExecutable(File file);

  String get lastUsedPrinter;

  set lastUsedPrinter(String printer);

  const SettingsRepository();

  factory SettingsRepository.fromPreferences(SharedPreferences prefs) =>
      _PrefsSettingsRepository(prefs);
}

class _PrefsSettingsRepository extends SettingsRepository {
  static const _kLastUsedPrinter = 'last_printer';
  static const _kRequestProcessorExec = 'requests_exec';

  final SharedPreferences _prefs;

  const _PrefsSettingsRepository(this._prefs) : assert(_prefs != null);

  @override
  File get requestsProcessorExecutable => File(
      _prefs.getString(_kRequestProcessorExec) ?? 'requests/bin/requests2.bat');

  @override
  set requestsProcessorExecutable(File file) =>
      _prefs.setString(_kRequestProcessorExec, file.absolute.path);

  @override
  String get lastUsedPrinter => _prefs.getString(_kLastUsedPrinter);

  @override
  set lastUsedPrinter(String printer) =>
      _prefs.setString(_kLastUsedPrinter, printer);
}
