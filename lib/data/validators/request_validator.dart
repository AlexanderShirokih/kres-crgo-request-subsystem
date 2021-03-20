import 'package:kres_requests2/data/validators/integer_validator.dart';
import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/data/validators/string_validator.dart';
import 'package:kres_requests2/domain/validator.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// [Validator] implementation that validates request instances
class RequestValidator extends MappedValidator<RequestEntity> {
  /// Creates new [RequestValidator] instance
  RequestValidator()
      : super({
          const IntegerValidator(
            fieldName: 'accountId',
            min: 0,
          ): (e) => e.accountId,
          const StringValidator(
            fieldName: 'name',
            minLength: 2,
            maxLength: 30,
          ): (e) => e.name,
          const StringValidator(
            fieldName: 'address',
            minLength: 5,
            maxLength: 30,
          ): (e) => e.address,
          const StringValidator(
            fieldName: 'counterInfo',
            canBeEmpty: true,
            minLength: 2,
            maxLength: 36,
          ): (e) => e.counterInfo,
          const StringValidator(
            fieldName: 'additionalInfo',
            canBeEmpty: true,
            minLength: 0,
            maxLength: 56,
          ): (e) => e.additionalInfo,
        });
}
