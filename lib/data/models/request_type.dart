import 'package:kres_requests2/data/repository/persisted_object.dart';
import 'package:kres_requests2/domain/controller/repository_controller.dart';
import 'package:kres_requests2/domain/models/request_type.dart';

/// Creates [RequestTypePersistedBuilder] factory that creates new persisted entities
class RequestTypePersistedBuilder
    implements PersistedObjectBuilder<RequestType> {
  const RequestTypePersistedBuilder();

  @override
  RequestType build(key, RequestType entity) => RequestTypeEntity(
        key,
        shortName: entity.shortName,
        fullName: entity.fullName,
      );
}

/// Position data object for storing in database
class RequestTypeEntity extends RequestType implements PersistedObject<int> {
  @override
  final int id;

  const RequestTypeEntity(
    this.id, {
    required String shortName,
    required String fullName,
  }) : super(shortName: shortName, fullName: fullName);

  @override
  List<Object> get props => [...super.props, id];

  @override
  RequestType copy({String? shortName, String? fullName}) => RequestTypeEntity(
        id,
        shortName: shortName ?? this.shortName,
        fullName: fullName ?? this.fullName,
      );
}
