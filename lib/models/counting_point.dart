import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:kres_requests2/models/encoder.dart';
import 'package:kres_requests2/models/entity.dart';

/// Describes API request for adding or updating counting point info's
class CountingPoint extends Equatable {
  /// Counter number
  final String counterNumber;

  /// Assigned counter type.
  final CounterType counterType;

  /// Transformation substation name
  final String tpName;

  /// Feeder number
  final int feederNumber;

  /// Pillar number
  final String pillarNumber;

  /// Nominal power
  final double power;

  /// Counter check year
  final int checkYear;

  /// Counter check quarter
  final int checkQuarter;

  const CountingPoint({
    this.counterNumber,
    this.counterType,
    this.tpName,
    this.feederNumber,
    this.pillarNumber,
    this.power,
    this.checkYear,
    this.checkQuarter,
  });

  String joinToString() {
    StringBuffer str = StringBuffer();

    str.write(counterType.name);
    str.write(' ');
    str.write(counterNumber);

    return str.toString();
  }

  static CountingPoint fromJson(Map<String, dynamic> data) => CountingPoint(
        counterNumber: data['counterNumber'],
        counterType: data['counterType'] == null
            ? null
            : CounterType.fromJson(data['counterType']),
        tpName: data['tpName'],
        feederNumber: data['feederNumber'],
        pillarNumber: data['pillarNumber'],
        power: data['power'],
        checkYear: data['checkYear'],
        checkQuarter: data['checkQuarter'],
      );

  @override
  List<Object> get props => [
        counterNumber,
        counterType,
        tpName,
        feederNumber,
        pillarNumber,
        power,
        checkYear,
        checkQuarter,
      ];
}

/// Describes information about counter type
class CounterType extends Equatable implements Entity<int> {
  /// Internal ID
  final int id;

  /// Counter type name
  final String name;

  /// Counter accuracy. Less value means more precise counter
  final CounterAccuracy accuracy;

  /// Counter bits count (before decimal place)
  final int bits;

  /// `true` if counter is single phased, `false` if it is tree phased
  final bool singlePhased;

  const CounterType({
    this.id,
    this.name,
    this.accuracy,
    this.bits,
    this.singlePhased,
  });

  static CounterType fromJson(Map<String, dynamic> data) =>
      encoder().fromJson(data);

  @override
  List<Object> get props => [
        id,
        name,
        accuracy,
        bits,
        singlePhased,
      ];

  @override
  int getId() => id;

  static Encoder<CounterType> encoder() => _CounterTypeEncoder();
}

class _CounterTypeEncoder extends Encoder<CounterType> {
  const _CounterTypeEncoder();

  @override
  CounterType fromJson(Map<String, dynamic> data) => CounterType(
        id: data['id'],
        name: data['name'],
        accuracy: data['accuracy'] == null
            ? null
            : getCounterAccuracyFromString(data['accuracy']),
        bits: data['bits'],
        singlePhased: data['singlePhased'],
      );

  @override
  Map<String, dynamic> toJson(CounterType e) => {
        'id': e.id,
        'name': e.name,
        'accuracy': e.accuracy == null ? null : describeEnum(e.accuracy),
        'bits': e.bits,
        'singlePhased': e.singlePhased,
      };
}

/// Describes a counter accuracy level
enum CounterAccuracy {
  /// Values less than 0.5
  HALF_MINUS,

  /// 0.5
  HALF,

  /// 1.0
  SINGLE,

  /// 2.0
  DOUBLE,

  /// 2.5
  DOUBLE_HALF,

  /// Values greater than 2.5
  DOUBLE_HALF_PLUS
}

extension CounterAccuracyExt on CounterAccuracy {
  String describeValue() {
    switch (this) {
      case CounterAccuracy.HALF_MINUS:
        return '<0.5';
      case CounterAccuracy.HALF:
        return '0.5';
      case CounterAccuracy.SINGLE:
        return '1.0';
      case CounterAccuracy.DOUBLE:
        return '2.0';
      case CounterAccuracy.DOUBLE_HALF:
        return '2.5';
      case CounterAccuracy.DOUBLE_HALF_PLUS:
        return '2.5<';
    }
    throw ('Unknown CounterAccuracy value: $this');
  }
}

CounterAccuracy getCounterAccuracyFromString(String type) {
  switch (type) {
    case "HALF_MINUS":
      return CounterAccuracy.HALF_MINUS;
    case "HALF":
      return CounterAccuracy.HALF;
    case "SINGLE":
      return CounterAccuracy.SINGLE;
    case "DOUBLE":
      return CounterAccuracy.DOUBLE;
    case "DOUBLE_HALF":
      return CounterAccuracy.DOUBLE_HALF;
    case "DOUBLE_HALF_PLUS":
      return CounterAccuracy.DOUBLE_HALF_PLUS;
    default:
      throw ('Unknown CounterAccuracy type: $type');
  }
}
