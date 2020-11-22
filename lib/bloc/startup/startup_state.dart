part of 'startup_bloc.dart';

/// Common abstract state for `StartupBloc`
abstract class StartupState extends Equatable {
  final User user;

  const StartupState(this.user);

  @override
  List<Object> get props => [user];
}

/// Initial startup state, nothing to do
class StartupInitial extends StartupState {
  const StartupInitial(User user) : super(user);
}

/// State when fetching recently opened documents begin
class StartupFetchingRecent extends StartupState {
  const StartupFetchingRecent(User user) : super(user);
}

/// State when recent documents list fetching has finished
class StartupGotRecentDocuments extends StartupState {
  final List<RequestSet> requests;
  final bool hasMore;
  final int currentPage;

  const StartupGotRecentDocuments(
      this.requests, this.hasMore, this.currentPage, User user)
      : assert(requests != null),
        assert(hasMore != null),
        assert(currentPage != null),
        super(user);
}

/// Indicates that fetching was failed
class StartupFetchingError extends StartupState {
  final ApiException exception;

  StartupFetchingError(User user, this.exception)
      : assert(exception != null),
        super(user);
}
