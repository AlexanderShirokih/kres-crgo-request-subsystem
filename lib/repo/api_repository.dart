import 'package:kres_requests2/data/models/server_response.dart';
import 'package:kres_requests2/repo/server_exception.dart';

/// Mixin for API repositories
mixin ApiRepositoryMixin {
  T getResponseData<T>(ServerResponse response, T Function(dynamic body) onOK) {
    if (response.isOk) {
      return onOK(response.body);
    }
    if (response.statusCode == 401) {
      throw UnauthorizedException(response.url);
    }

    throw ApiException(response.error.toString(), response.url);
  }

  void ensureOk(ServerResponse response) =>
      getResponseData(response, (body) {});
}
