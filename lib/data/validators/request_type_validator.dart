import 'package:kres_requests2/data/validators/string_validator.dart';
import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/validator.dart';

import 'mapped_validator.dart';

/// [Validator] implementation that validates request type instances
class RequestTypeValidator extends MappedValidator<RequestType> {
  /// Creates new [RequestTypeValidator] instance
  RequestTypeValidator()
      : super({
          const StringValidator(
            fieldName: 'shortName',
            minLength: 3,
            maxLength: 10,
          ): (e) => e.shortName,
          const StringValidator(
            fieldName: 'fullName',
            minLength: 5,
            maxLength: 20,
          ): (e) => e.fullName,
        });
}
