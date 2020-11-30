/// Converts quarter from integer to roman string representation
String quarterToString(int quarter) {
  switch (quarter) {
    case 1:
      return 'I';
    case 2:
      return 'II';
    case 3:
      return 'III';
    case 4:
      return 'IV';
    default:
      return null;
  }
}
