import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/models/encoder.dart';
import 'package:kres_requests2/models/entity.dart';
import 'package:kres_requests2/repo/api_repository.dart';

/// Common CRD (without update) repository which implements base operations
/// on some data source
/// On remote source will be executed requests:
/// - For adding a new entity:            POST   requestPath/
/// - For removing existing entity:       DELETE requestPath/{id}
/// - For getting a list of all entities: GET requestPath/
class BaseCRUDRepository<E extends Entity<int>> with ApiRepositoryMixin {
  final ApiServer _apiServer;
  final Encoder<E> _encoder;
  final String _requestPath;

  const BaseCRUDRepository(
    this._apiServer,
    this._encoder,
    this._requestPath,
  )   : assert(_requestPath != null),
        assert(_encoder != null),
        assert(_apiServer != null);

  /// Returns list containing all items in the data source
  /// If some network error happens throws `ApiException`.
  /// Throws `UnauthorizedException` if user has no rights to access data
  Future<List<E>> getAll() async {
    final response = await _apiServer.getData(ServerRequest.get(_requestPath));

    return getResponseData(
      response,
      (body) =>
          (body as List<dynamic>).map((e) => _encoder.fromJson(e)).toList(),
    );
  }

  /// Adds new entity to the data source
  /// If some network error happens throws `ApiException`.
  /// Throws `UnauthorizedException` if user has no rights to save data
  Future save(E entity) async {
    final response = await _apiServer.getData(
      ServerRequest.post(_requestPath, body: _encoder.toJson(entity)),
    );

    ensureOk(response);
  }

  /// Deletes entity from list
  /// If some network error happens throws `ApiException`.
  /// Throws `UnauthorizedException` if user has no rights to save data
  Future delete(E entity) async {
    final response = await _apiServer.getData(
      ServerRequest.delete('$_requestPath/${entity.getId()}'),
    );

    ensureOk(response);
  }
}
