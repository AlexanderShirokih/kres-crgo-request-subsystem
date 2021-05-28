import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/utils.dart';

/// Describes electrical counter info
class CounterInfo extends Equatable {
  /// Counter type
  final String type;

  /// Personal counter number
  final String number;

  /// Checking quarter
  final int? checkQuarter;

  /// Checking year
  final int? checkYear;

  /// Returns `true` is all fields are empty
  bool get isEmpty =>
      checkQuarter == null &&
      checkYear == null &&
      type.isEmpty &&
      number.isEmpty;

  const CounterInfo({
    required this.type,
    required this.number,
    this.checkQuarter,
    int? checkYear,
  }) : checkYear = checkYear != null && checkYear > 0 && checkYear < 100
            ? 2000 + checkYear
            : checkYear;

  /// Returns formatted number and type
  String get mainInfo => '№$number $type';

  /// Returns formatted checking info. No checking info provided - result
  /// string will be empty
  String get checkInfo {
    if (checkQuarter == null && checkYear == null) {
      return '';
    }

    return 'п. ${checkQuarter?.romanGroup ?? '?'}-${checkYear?.toString().substring(2) ?? '?'}';
  }

  /// Returns full printable string representation
  String get fullInfo => [mainInfo, checkInfo].join(' | ');

  @override
  List<Object?> get props => [type, number, checkQuarter, checkYear];
}
