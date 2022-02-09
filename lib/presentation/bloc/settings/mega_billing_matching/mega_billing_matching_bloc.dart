import 'dart:async';

import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/lazy.dart';
import 'package:kres_requests2/domain/models/mega_billing_matching.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_bloc.dart';
import 'package:kres_requests2/presentation/bloc/settings/common/undoable_events.dart';
import 'package:kres_requests2/presentation/bloc/settings/mega_billing_matching/mega_billing_matching_data.dart';
import 'package:list_ext/list_ext.dart';

/// BLoC that handles actions on mega-billing matching list
class MegaBillingMatchingBloc
    extends UndoableBloc<MegaBillingMatchingData, MegaBillingMatching> {
  final Repository<RequestType> _requestTypesRepository;
  final AsyncLazy<RequestType> _defaultRequestType;

  /// Creates new [RequestTypeBloc] and starts fetching request type list
  MegaBillingMatchingBloc(
    StreamedRepositoryController<MegaBillingMatching> controller,
    Validator<MegaBillingMatching> validator,
    this._requestTypesRepository,
  )   : _defaultRequestType = AsyncLazy(),
        super(controller, validator);

  @override
  Future<MegaBillingMatching> createNewEntity() async => MegaBillingMatching(
        megaBillingNaming: '',
        requestType: await _defaultRequestType.call(
          () async {
            final def = (await _requestTypesRepository.getAll()).firstOrNull;
            if (def == null) {
              add(const MissingDependencyEvent());
              return RequestType.fallback;
            }
            return def;
          },
        ),
      );

  @override
  Future<MegaBillingMatchingData> onRefreshData(
          List<MegaBillingMatching> data) async =>
      MegaBillingMatchingData(
        data: data,
        availableRequestTypes: await _requestTypesRepository.getAll(),
      );
}
