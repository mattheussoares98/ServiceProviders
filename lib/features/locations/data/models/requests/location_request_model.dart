import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';

class LocationRequestModel extends LocationEntity
    implements DataConvertible<LocationEntity> {
  const LocationRequestModel({
    required super.id,
    required super.companyId,
    required super.name,
    super.address,
    super.city,
    super.state,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory LocationRequestModel.fromEntity(LocationEntity entity) =>
      LocationRequestModel(
        id: entity.id,
        companyId: entity.companyId,
        name: entity.name,
        address: entity.address,
        city: entity.city,
        state: entity.state,
        isActive: entity.isActive,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        deletedAt: entity.deletedAt,
      );

  factory LocationRequestModel.fromJson(MapDynamic json) =>
      LocationRequestModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        address: json['address'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
      );

  @override
  MapDynamic toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  @override
  LocationEntity toEntity() => LocationEntity(
        id: id,
        companyId: companyId,
        name: name,
        address: address,
        city: city,
        state: state,
        isActive: isActive,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );
}
