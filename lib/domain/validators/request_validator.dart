import 'package:kres_requests2/domain/domain.dart';
import 'package:kres_requests2/domain/validators.dart';

/// [Validator] implementation that validates request instances
class RequestValidator extends MappedValidator<Request> {
  static const account = 'accountId';
  static const requestType = 'requestType';
  static const name = 'name';
  static const address = 'address';
  static const phone = 'phone';
  static const tp = 'tp';
  static const line = 'line';
  static const pillar = 'pillar';
  static const additionalInfo = 'additionalInfo';

  /// Creates new [RequestValidator] instance
  RequestValidator()
      : super([
          ValidationEntry(
              name: account,
              localName: 'Лицевой счет',
              validator: const IntegerValidator(
                min: 0,
              ),
              fieldSelector: (e) => e.accountId),
          ValidationEntry(
              name: requestType,
              localName: 'Тип заявки',
              validator: RequestTypeValidator(),
              fieldSelector: (e) => e.requestType),
          ValidationEntry(
              name: name,
              localName: 'ФИО',
              validator: const StringValidator(maxLength: 50),
              fieldSelector: (e) => e.name),
          ValidationEntry(
              name: address,
              localName: 'Адрес',
              validator: const StringValidator(maxLength: 50),
              fieldSelector: (e) => e.address),
          ValidationEntry(
              name: phone,
              localName: 'Телефон',
              validator: const StringValidator(maxLength: 15),
              fieldSelector: (e) => e.phoneNumber),
          ValidationEntry(
              name: tp,
              localName: 'ТП',
              validator: const StringValidator(maxLength: 6),
              fieldSelector: (e) => e.connectionPoint?.tp),
          ValidationEntry(
              name: line,
              localName: 'Линия',
              validator: const StringValidator(maxLength: 3),
              fieldSelector: (e) => e.connectionPoint?.line),
          ValidationEntry(
              name: pillar,
              localName: 'Опора',
              validator: const StringValidator(maxLength: 6),
              fieldSelector: (e) => e.connectionPoint?.pillar),
          ValidationEntry(
              name: additionalInfo,
              localName: 'Дополнительно',
              validator: const StringValidator(
                minLength: 0,
                maxLength: 35,
              ),
              fieldSelector: (e) => e.additionalInfo),
        ]);
}
