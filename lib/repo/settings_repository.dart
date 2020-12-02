import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsRepository {
  String get lastUsedPrinter;

  set lastUsedPrinter(String printer);

  const SettingsRepository();

  factory SettingsRepository.fromPreferences(SharedPreferences prefs) =>
      _PrefsSettingsRepository(prefs);
}

class _PrefsSettingsRepository extends SettingsRepository {
  static const _kLastUsedPrinter = 'last_printer';

  final SharedPreferences _prefs;

  const _PrefsSettingsRepository(this._prefs) : assert(_prefs != null);

  @override
  String get lastUsedPrinter => _prefs.getString(_kLastUsedPrinter);

  @override
  set lastUsedPrinter(String printer) =>
      _prefs.setString(_kLastUsedPrinter, printer);
}
