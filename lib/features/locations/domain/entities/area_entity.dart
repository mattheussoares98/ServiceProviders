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
    bool? annulFloor,
    bool? annulDescription,
    bool? annulDeletedAt,
  }) {
    return AreaEntity(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      floor: annulFloor == true ? null : floor ?? this.floor,
      description: annulDescription == true ? null : description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
