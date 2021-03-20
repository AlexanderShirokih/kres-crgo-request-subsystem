import 'dart:convert';
import 'dart:io';

class ConfigRepository {
  final Map<String, dynamic> _requestsProcessInfoData;

  ConfigRepository(this._requestsProcessInfoData);

  static Future<ConfigRepository> create() async {
    final requestsProcessInfo = await File('requests_processor_classpath.json')
        .readAsString()
        .then((value) => jsonDecode(value));
    return ConfigRepository(requestsProcessInfo);
  }

  Map<String, dynamic> getRequestsProcessInfoData() => _requestsProcessInfoData;
}
