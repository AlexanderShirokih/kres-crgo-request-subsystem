import 'package:kres_requests2/domain/models/request_type.dart';
import 'package:kres_requests2/domain/validators.dart';


/// [Validator] implementation that validates request type instances
class RequestTypeValidator extends MappedValidator<RequestType> {
  /// Creates new [RequestTypeValidator] instance
  RequestTypeValidator()
      : super([
          ValidationEntry(
              name: 'shortName',
              localName: 'Короткое название',
              validator: const StringValidator(
                minLength: 3,
                maxLength: 10,
              ),
              fieldSelector: (e) => e.shortName),
          ValidationEntry(
              name: 'fullName',
              localName: 'Полное название',
              validator: const StringValidator(
                minLength: 5,
                maxLength: 20,
              ),
              fieldSelector: (e) => e.fullName),
        ]);
}
