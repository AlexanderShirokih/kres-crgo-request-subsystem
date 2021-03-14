import 'package:equatable/equatable.dart';

/// Describes request type
class RequestType extends Equatable {
  /// Request type short name
  final String shortName;

  /// Request type full name
  final String fullName;

  const RequestType({required this.shortName, required this.fullName});

  @override
  List<Object> get props => [shortName, fullName];

  /// Creates a copy with customized parameters
  RequestType copy({String? shortName, String? fullName}) => RequestType(
        shortName: shortName ?? this.shortName,
        fullName: fullName ?? this.fullName,
      );
}
