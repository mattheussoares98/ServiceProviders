import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  const LocationEntity({
    required this.id,
    required this.companyId,
    required this.name,
    this.address,
    this.city,
    this.state,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
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
    bool? annulAddress,
    bool? annulCity,
    bool? annulState,
    bool? annulDeletedAt,
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
    );
  }
}
