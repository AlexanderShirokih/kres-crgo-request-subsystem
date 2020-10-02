class ConfigRepository {
  static const _reqMap = <String, String>{
    "замена": "Замена ПУ",
    "по сроку": "Замена ПУ",
    "вывод": "Распломбировка",
    "опломб.": "Опломбировка",
    "распломб.": "Распломбировка",
    "тех. пров.": "Тех. Проверка",
    "подкл.": "Подключение",
  };

  // TODO: Make full implementation
  String getFullRequestName(String shortName) {
    return _reqMap[shortName] ?? null;
  }
}
