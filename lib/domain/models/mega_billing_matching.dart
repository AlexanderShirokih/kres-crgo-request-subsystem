import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/domain.dart';

/// Describes matching mega-billing request type to internal request types
class MegaBillingMatching extends Equatable {
  /// Mega-billing request type naming
  final String megaBillingNaming;

  /// Internal request type association
  final RequestType requestType;

  const MegaBillingMatching({
    required this.megaBillingNaming,
    required this.requestType,
  });

  @override
  List<Object?> get props => [megaBillingNaming, requestType];

  /// Creates a copy with customized parameters
  MegaBillingMatching copy({
    String? megaBillingNaming,
    RequestType? requestType,
  }) =>
      MegaBillingMatching(
        megaBillingNaming: megaBillingNaming ?? this.megaBillingNaming,
        requestType: requestType ?? this.requestType,
      );
}
