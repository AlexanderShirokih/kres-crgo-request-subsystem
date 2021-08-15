import 'package:kres_requests2/domain/editor/decoding_pipeline.dart';
import 'package:kres_requests2/domain/models.dart';
import 'package:kres_requests2/domain/repository/mega_billing_matching_repository.dart';

class MegaBillingDecodingPipeline extends DecodingPipeline {
  final MegaBillingMatchingRepository _matchingRepository;

  MegaBillingDecodingPipeline(this._matchingRepository);

  @override
  Future<RequestType> processRequestType(RequestType requestType) async {
    // Enhancement: Convert domain layer models to interface
    // final megaRequest = requestType as MegaBillingRequestType;
    final megabillingRequestName = requestType.shortName;

    final newRequestType =
        await _matchingRepository.findByName(megabillingRequestName);

    return newRequestType ?? requestType;
  }
}
