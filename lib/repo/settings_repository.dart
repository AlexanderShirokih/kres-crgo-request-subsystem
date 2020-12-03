import 'package:shared_preferences/shared_preferences.dart';

/// Global settings repository
abstract class SettingsRepository {
  String get serverHost;

  set serverHost(String host);

  String get lastUsedPrinter;

  set lastUsedPrinter(String printer);

  const SettingsRepository();

  factory SettingsRepository.fromPreferences(SharedPreferences prefs) =>
      _PrefsSettingsRepository(prefs);
}

class _PrefsSettingsRepository extends SettingsRepository {
  static const _kLastUsedPrinter = 'last_printer';
  static const _kLastServer = 'server_host';

  final SharedPreferences _prefs;

  const _PrefsSettingsRepository(this._prefs) : assert(_prefs != null);

  @override
  String get lastUsedPrinter => _prefs.getString(_kLastUsedPrinter);

  @override
  set lastUsedPrinter(String printer) =>
      _prefs.setString(_kLastUsedPrinter, printer);

  @override
  String get serverHost => _prefs.getString(_kLastServer);

  @override
  set serverHost(String host) => _prefs.setString(_kLastServer, host);
}
