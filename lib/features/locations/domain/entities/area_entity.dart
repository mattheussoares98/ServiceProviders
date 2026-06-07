import 'package:equatable/equatable.dart';

class AreaEntity extends Equatable {
  const AreaEntity({
    required this.id,
    required this.locationId,
    required this.companyId,
    required this.name,
    this.floor,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String locationId;
  final String companyId;
  final String name;
  final String? floor;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        locationId,
        companyId,
        name,
        floor,
        description,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  AreaEntity copyWith({
    String? id,
    String? locationId,
    String? companyId,
    String? name,
    String? floor,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AreaEntity(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      floor: floor ?? this.floor,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  AreaEntity annulFloor() => AreaEntity(
        id: id,
        locationId: locationId,
        companyId: companyId,
        name: name,
        floor: null,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AreaEntity annulDescription() => AreaEntity(
        id: id,
        locationId: locationId,
        companyId: companyId,
        name: name,
        floor: floor,
        description: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  AreaEntity annulDeletedAt() => AreaEntity(
        id: id,
        locationId: locationId,
        companyId: companyId,
        name: name,
        floor: floor,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );
}
