import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Defines base abstract state for BLoCs
@sealed
abstract class BaseState extends Equatable {
  const BaseState();
}

/// State used when data is not starts loading yet
class InitialState extends BaseState {
  const InitialState();

  @override
  List<Object?> get props => [];
}

/// Defines state when data is loading
class LoadingState extends BaseState {
  @override
  List<Object?> get props => [];
}

/// Defines state when data is ready
class DataState<T> extends BaseState {
  final T data;

  const DataState(this.data);

  @override
  List<Object?> get props => [data];
}

/// Defines state when unhandled error thrown
class ErrorState extends BaseState {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorState(this.error, [this.stackTrace]);

  @override
  List<Object?> get props => [error, stackTrace];
}
