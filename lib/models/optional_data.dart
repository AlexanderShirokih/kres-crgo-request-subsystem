import 'package:equatable/equatable.dart';

/// Wrapped class that contains error an stack trace
class ErrorWrapper extends Equatable {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorWrapper(this.error, this.stackTrace);

  @override
  List<Object?> get props => [error, stackTrace];
}

/// Wrapper that contains either data or error
class OptionalData<T> extends Equatable {
  final T? data;
  final ErrorWrapper? error;

  const OptionalData({this.data, this.error})
      : assert(data != null || error != null);

  /// Creates [OptionalData] from error
  static OptionalData ofError<T>(Object errorObject, StackTrace? stackTrace) =>
      OptionalData<T>(
        error: ErrorWrapper(
          errorObject,
          stackTrace,
        ),
      );

  bool hasError() => error != null;

  @override
  List<Object?> get props => [data, error];
}
