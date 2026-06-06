import 'package:equatable/equatable.dart';

final class AreaEntity extends Equatable {
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
}
