import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kres_requests2/models/request_set.dart';
import 'package:kres_requests2/models/user.dart';
import 'package:kres_requests2/repo/request_set_repository.dart';
import 'package:kres_requests2/repo/server_exception.dart';
import 'package:kres_requests2/repo/users_repository.dart';

part 'startup_event.dart';

part 'startup_state.dart';

/// BLoC class for managing startup screen state
class StartupBloc extends Bloc<StartupEvent, StartupState> {
  final UsersRepository _usersRepository;
  final RequestsSetRepository _requestSetRepository;

  StartupBloc(this._usersRepository, this._requestSetRepository)
      : assert(_usersRepository != null),
        assert(_requestSetRepository != null),
        super(StartupInitial(
          const User(name: "--", hasModerationRights: false),
        )) {
    _usersRepository
        .getUserDetails()
        .then((user) => this.add(StartupGotUserEvent(user)));
  }

  @override
  Stream<StartupState> mapEventToState(
    StartupEvent event,
  ) async* {
    if (event is StartupGotUserEvent) {
      yield StartupInitial(event.user);
      add(StartupFetchRecent());
    } else if (event is StartupFetchRecent) {
      yield* _fetchRecent(state.user, event.expand);
    } else if (event is StartupGotUserEvent) {
      // TODO: Handle case
    } else if (event is StartupCreateNewRequestsSet) {
      // TODO: Handle case
    }
  }

  Stream<StartupState> _fetchRecent(User user, bool expandList) async* {
    var nextPage = 0;
    if (state is StartupGotRecentDocuments && expandList) {
      nextPage = (state as StartupGotRecentDocuments).currentPage + 1;
    }

    yield StartupFetchingRecent(user);

    try {
      final requestsSet = await _requestSetRepository.getRequestSets(nextPage);

      yield StartupGotRecentDocuments(
        requestsSet.requestsSets,
        requestsSet.hasMore,
        requestsSet.upperBoundPage,
        user,
      );
    } on ApiException catch (apiException) {
      yield StartupFetchingError(user, apiException);
    }
  }
}
