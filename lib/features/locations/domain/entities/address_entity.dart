import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  const AddressEntity({
    required this.postalCode,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.complement,
  });

  final String postalCode;
  final String street;
  final String neighborhood;
  final String city;
  final String state;
  final String? complement;

  @override
  List<Object?> get props => [
    postalCode,
    street,
    neighborhood,
    city,
    state,
    complement,
  ];

  AddressEntity copyWith({
    String? postalCode,
    String? street,
    String? neighborhood,
    String? city,
    String? state,
    String? complement,
    bool? annulComplement,
  }) {
    return AddressEntity(
      postalCode: postalCode ?? this.postalCode,
      street: street ?? this.street,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      complement: annulComplement == true ? null : complement ?? this.complement,
    );
  }
}
