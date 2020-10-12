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

  static const _reqMap = <String, String>{
    "замена": "Замена ПУ",
    "вывод": "Распломбировка",
    "опломб.": "Опломбировка",
    "распломб.": "Распломбировка",
    "тех. пров.": "Проверка схем учёта",
    "ЦОП": "Проверка схем учёта",
    "подкл.": "Подключение",
    "откл.": "Отключение",
  };

  // TODO: Make full implementation
  String getFullRequestName(String shortName) {
    return _reqMap[shortName] ?? null;
  }
}
