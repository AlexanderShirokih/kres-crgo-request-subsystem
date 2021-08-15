import 'package:kres_requests2/domain/models/request_type.dart';

class DecodingPipeline {
  const DecodingPipeline();

  /// Processes request type
  Future<RequestType> processRequestType(RequestType requestType) =>
      Future.value(requestType);
}
