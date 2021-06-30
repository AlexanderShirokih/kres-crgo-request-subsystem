import 'package:equatable/equatable.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/screens/bloc/settings/common/undoable_data.dart';

/// Data holder for request type BLoC
class RequestTypeData extends Equatable
    implements UndoableDataHolder<RequestType> {
  /// List of all request types
  @override
  final List<RequestType> data;

  RequestTypeData(this.data);

  @override
  List<Object?> get props => [data];
}
