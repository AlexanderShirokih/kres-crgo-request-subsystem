import 'dart:async';

import 'package:kres_requests2/domain/controller/streamed_controller.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/validator.dart';
import 'package:kres_requests2/screens/bloc/settings/common/undoable_bloc.dart';
import 'package:kres_requests2/screens/bloc/settings/request_types/request_type_data.dart';

/// BLoC that handles actions on request type list
class RequestTypeBloc extends UndoableBloc<RequestTypeData, RequestType> {
  /// Creates new [RequestTypeBloc] and starts fetching request type list
  RequestTypeBloc(
    StreamedRepositoryController<RequestType> controller,
    Validator<RequestType> validator,
  ) : super(controller, validator);

  @override
  Future<RequestType> createNewEntity() async => RequestType(
        shortName: '',
        fullName: '',
      );

  @override
  Future<RequestTypeData> onRefreshData(List<RequestType> data) async =>
      RequestTypeData(data);
}
