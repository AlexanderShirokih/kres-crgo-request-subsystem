import 'package:equatable/equatable.dart';

class ErrorWrapper extends Equatable {
  final String error;
  final String stackTrace;

  const ErrorWrapper(this.error, this.stackTrace);

  @override
  List<Object> get props => [error, stackTrace];

  bool isNotEmpty() => error.isNotEmpty || stackTrace.isNotEmpty;

}

class OptionalData<T> extends Equatable {
  final T data;
  final ErrorWrapper error;

  const OptionalData({this.data, this.error})
      : assert(data != null || error != null);

  bool hasError() => error != null && error.isNotEmpty();

  @override
  List<Object> get props => [data, error];
}
