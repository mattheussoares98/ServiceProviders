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
  }) {
    return LocationEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  LocationEntity annulAddress() => LocationEntity(
        id: id,
        companyId: companyId,
        name: name,
        address: null,
        city: city,
        state: state,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  LocationEntity annulCity() => LocationEntity(
        id: id,
        companyId: companyId,
        name: name,
        address: address,
        city: null,
        state: state,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  LocationEntity annulState() => LocationEntity(
        id: id,
        companyId: companyId,
        name: name,
        address: address,
        city: city,
        state: null,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  LocationEntity annulDeletedAt() => LocationEntity(
        id: id,
        companyId: companyId,
        name: name,
        address: address,
        city: city,
        state: state,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );
}
