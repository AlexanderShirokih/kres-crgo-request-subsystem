/// Used to convert integer to roman number in range [1,5]
extension RomanGroupExtension on int {
  String get romanGroup {
    switch (this) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      case 4:
        return 'IV';
      case 5:
        return 'V';
      default:
        return toString();
    }
  }
}
