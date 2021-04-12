import 'package:kres_requests2/data/validators.dart';
import 'package:kres_requests2/data/validators/integer_validator.dart';
import 'package:kres_requests2/data/validators/mapped_validator.dart';
import 'package:kres_requests2/data/validators/string_validator.dart';
import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/validator.dart';
import 'package:kres_requests2/models/request_entity.dart';

/// [Validator] implementation that validates request instances
class RequestValidator extends MappedValidator<RequestEntity> {
  static const account = 'accountId';
  static const requestType = 'requestType';
  static const name = 'name';
  static const address = 'address';
  static const phone = 'phone';
  static const tp = 'tp';
  static const line = 'line';
  static const pillar = 'pillar';

  /// Creates new [RequestValidator] instance
  RequestValidator()
      : super([
          ValidationEntry(
              account,
              const IntegerValidator(
                min: 0,
              ),
              (e) => e.accountId),
          ValidationEntry(
              requestType, RequestTypeValidator(), (e) => e.requestType),
          ValidationEntry(
              name, const StringValidator(maxLength: 30), (e) => e.name),
          ValidationEntry(
              address, const StringValidator(maxLength: 30), (e) => e.address),
          ValidationEntry(
              phone, StringValidator(maxLength: 15), (e) => e.phoneNumber),
          ValidationEntry(tp, const StringValidator(maxLength: 6),
              (e) => e.connectionPoint?.tp ?? ''),
          ValidationEntry(line, const StringValidator(maxLength: 3),
              (e) => e.connectionPoint?.line ?? ''),
          ValidationEntry(pillar, const StringValidator(maxLength: 6),
              (e) => e.connectionPoint?.pillar ?? ''),
          ValidationEntry(
              'additionalInfo',
              const StringValidator(
                minLength: 0,
                maxLength: 30,
              ),
              (e) => e.additionalInfo),
        ]);
}
