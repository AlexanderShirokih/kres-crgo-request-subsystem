import 'package:kres_requests2/models/request_set.dart';

/// Responsible for requests data validation
class RequestSetValidator {
  final RequestSet _requestSet;

  const RequestSetValidator(this._requestSet) : assert(_requestSet != null);

  /// Validates the request set and returns list of errors
  Iterable<String> validate() {
    // TODO:
    return [];
  }

  /// Returns `true` is the request set has no errors
  bool hasErrors() => validate().isNotEmpty;
}
