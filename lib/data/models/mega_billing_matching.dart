import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models/mega_billing_matching.dart';

/// Creates [PersistedObjectBuilder] factory that creates new persisted entities
class MegaBillingMatchingPersistedBuilder
    implements PersistedObjectBuilder<MegaBillingMatching> {
  const MegaBillingMatchingPersistedBuilder();

  @override
  MegaBillingMatching build(key, MegaBillingMatching entity) =>
      MegaBillingMatchingEntity(
        key,
        megaBillingNaming: entity.megaBillingNaming,
        requestType: entity.requestType,
      );
}

class MegaBillingMatchingEntity extends MegaBillingMatching
    implements PersistedObject<int> {
  @override
  final int id;

  const MegaBillingMatchingEntity(
    this.id, {
    required String megaBillingNaming,
    required RequestType requestType,
  }) : super(
          megaBillingNaming: megaBillingNaming,
          requestType: requestType,
        );

  @override
  List<Object?> get props => [id, ...super.props];

  @override
  MegaBillingMatching copy({
    String? megaBillingNaming,
    RequestType? requestType,
  }) =>
      MegaBillingMatchingEntity(
        id,
        megaBillingNaming: megaBillingNaming ?? this.megaBillingNaming,
        requestType: requestType ?? this.requestType,
      );
}
