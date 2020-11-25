import 'package:equatable/equatable.dart';

import 'address.dart';

/// Describes model containing account info
class AccountInfo extends Equatable {
  /// Account info ID (account number)
  final int baseId;

  /// Account owner name
  final String name;

  /// User address: street name
  final Street street;

  /// User address: home number
  final String homeNumber;

  /// User address: apartment number
  final String apartmentNumber;

  /// User phone number
  final String phoneNumber;

  const AccountInfo({
    this.baseId,
    this.name,
    this.street,
    this.homeNumber,
    this.apartmentNumber,
    this.phoneNumber,
  });

  /// Returns full address representation
  String joinAddress() {
    StringBuffer str = StringBuffer();
    if (street != null) {
      str.write(street.name);
      str.write(' ');
    }
    if (homeNumber != null && homeNumber.isNotEmpty) {
      str.write('д. ');
      str.write(homeNumber);
    }
    if (apartmentNumber != null && apartmentNumber.isNotEmpty) {
      str.write(' кв.');
      str.write(apartmentNumber);
    }
    return str.toString();
  }

  static AccountInfo fromJson(Map<String, dynamic> data) => AccountInfo(
        baseId: data['baseId'],
        name: data['name'],
        street: data['street'] == null ? null : Street.fromJson(data['street']),
        homeNumber: data['homeNumber'],
        apartmentNumber: data['apartmentNumber'],
        phoneNumber: data['phoneNumber'],
      );

  @override
  List<Object> get props => [
        baseId,
        name,
        street,
        homeNumber,
        apartmentNumber,
        phoneNumber,
      ];
}
