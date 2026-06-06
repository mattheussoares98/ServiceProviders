import 'package:equatable/equatable.dart';

final class LocationEntity extends Equatable {
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
}
