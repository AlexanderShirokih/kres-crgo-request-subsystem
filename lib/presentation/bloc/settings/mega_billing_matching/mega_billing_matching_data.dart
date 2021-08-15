import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/models/mega_billing_matching.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_data.dart';

/// Data holder for request type BLoC
class MegaBillingMatchingData extends Equatable
    implements UndoableDataHolder<MegaBillingMatching> {
  /// List of all associations
  @override
  final List<MegaBillingMatching> data;

  /// List of all available positions
  final List<RequestType> availableRequestTypes;

  const MegaBillingMatchingData({
    required this.data,
    required this.availableRequestTypes,
  });

  @override
  List<Object?> get props => [data, availableRequestTypes];
}
