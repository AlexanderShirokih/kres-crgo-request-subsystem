import 'package:equatable/equatable.dart';

/// Describes information about connection point
class ConnectionPoint extends Equatable {
  // Transformer substation
  final String? tp;

  // Power line
  final String? line;

  // Connection pillar
  final String? pillar;

  const ConnectionPoint({
    this.tp,
    this.line,
    this.pillar,
  });

  @override
  List<Object?> get props => [tp, line, pillar];
}
