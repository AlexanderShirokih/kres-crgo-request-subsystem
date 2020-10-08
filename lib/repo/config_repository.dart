class ConfigRepository {
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
