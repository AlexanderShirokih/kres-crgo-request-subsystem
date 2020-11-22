part of 'startup_bloc.dart';

abstract class StartupEvent extends Equatable {
  const StartupEvent();
}

/// Used when we got the user account details
class StartupGotUserEvent extends StartupEvent {
  final User user;

  StartupGotUserEvent(this.user) : assert(user != null);

  @override
  List<Object> get props => [user];
}

/// Used to trigger recent items update
class StartupFetchRecent extends StartupEvent {
  final bool expand;

  StartupFetchRecent([this.expand = false]);

  @override
  List<Object> get props => [expand];
}

/// Used to open chosen requests set
class StartupOpenRequestsSet extends StartupEvent {
  final RequestSet chosenRequestsSet;

  StartupOpenRequestsSet(this.chosenRequestsSet)
      : assert(chosenRequestsSet != null);

  @override
  List<Object> get props => [chosenRequestsSet];
}

enum RequestsSetSource { New, ImportMegaBilling }

/// Used to create new requests set from scratch or by importing from
/// another request systems
class StartupCreateNewRequestsSet extends StartupEvent {
  final RequestsSetSource source;

  StartupCreateNewRequestsSet(this.source) : assert(source != null);

  @override
  List<Object> get props => [source];
}
