import 'package:kres_requests2/domain/models/mega_billing_matching.dart';
import 'package:kres_requests2/domain/validators.dart';

/// [Validator] implementation that validates mega-billing associations instances
class MegaBillingMatchValidator extends MappedValidator<MegaBillingMatching> {
  /// Creates new [MegaBillingMatchValidator] instance
  MegaBillingMatchValidator()
      : super([
          ValidationEntry(
            name: 'mb_match',
            localName: 'Тип Mega-billing',
            validator: const StringValidator(
              minLength: 3,
              maxLength: 30,
            ),
            fieldSelector: (e) => e.megaBillingNaming,
          )
        ]);
}
