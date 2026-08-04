import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  const LocationEntity({
    required this.id,
    required this.companyId,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    required this.number,
    required this.complement,
    required this.neighborhood,
    required this.postalCode,
  });

  final String id;
  final String companyId;
  final String name;
  final String? address;
  final String? city;
  final String? state;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? number;
  final String? complement;
  final String? neighborhood;
  final String? postalCode;

  @override
  List<Object?> get props => [
    id,
    companyId,
    name,
    address,
    city,
    state,
    isActive,
    createdAt,
    updatedAt,
    deletedAt,
  ];

  LocationEntity copyWith({
    String? id,
    String? companyId,
    String? name,
    String? address,
    String? city,
    String? state,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? number,
    String? complement,
    String? neighborhood,
    String? postalCode,
    bool? annulAddress,
    bool? annulCity,
    bool? annulState,
    bool? annulDeletedAt,
    bool? annulNumber,
    bool? annulComplement,
    bool? annulNeighborhood,
    bool? annulPostalCode,
  }) {
    return LocationEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      address: annulAddress == true ? null : address ?? this.address,
      city: annulCity == true ? null : city ?? this.city,
      state: annulState == true ? null : state ?? this.state,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
      number: annulNumber == true ? null : number ?? this.number,
      complement: annulComplement == true
          ? null
          : complement ?? this.complement,
      neighborhood: annulNeighborhood == true
          ? null
          : neighborhood ?? this.neighborhood,
      postalCode: annulPostalCode == true
          ? null
          : postalCode ?? this.postalCode,
    );
  }
}
