import 'package:kres_requests2/data/api_server.dart';
import 'package:kres_requests2/data/models/server_request.dart';
import 'package:kres_requests2/repo/api_repository.dart';

/// Common CRD (without update) repository which implements base operations
/// on some data source
/// On remote source will be executed requests:
/// - For adding a new entity:            POST   requestPath/
/// - For removing existing entity:       DELETE requestPath/{id}
/// - For getting a list of all entities: GET requestPath/
abstract class BaseCRUDRepository<E> with ApiRepositoryMixin {
  final ApiServer _apiServer;
  final String _requestPath;

  const BaseCRUDRepository(
    this._apiServer,
    this._requestPath,
  )   : assert(_requestPath != null),
        assert(_apiServer != null);

  /// Returns list containing all items in the data source
  /// If some network error happens throws `ApiException`.
  /// Throws `UnauthorizedException` if user has no rights to access data
  Future<List<E>> getAll() async {
    final response = await _apiServer.getData(ServerRequest.get(_requestPath));

    return getResponseData(
      response,
      (body) => (body as List<dynamic>).map((e) => fromJson(e)).toList(),
    );
  }

  /// Adds new entity to the data source
  /// If some network error happens throws `ApiException`.
  /// Throws `UnauthorizedException` if user has no rights to save data
  Future save(E entity) async {
    final response = await _apiServer.getData(
      ServerRequest.post(_requestPath, body: toJson(entity)),
    );

    ensureOk(response);
  }

  /// Deletes entity from list
  /// If some network error happens throws `ApiException`.
  /// Throws `UnauthorizedException` if user has no rights to save data
  Future delete(E entity) async {
    final response = await _apiServer.getData(
      ServerRequest.delete('$_requestPath/${getId(entity)}'),
    );

    ensureOk(response);
  }

  /// Decodes JSON representation of object to its instance
  E fromJson(dynamic data);

  /// Encodes object instance to its JSON representation
  dynamic toJson(E entity);

  /// Extracts ID from the entity
  int getId(E entity);
}
