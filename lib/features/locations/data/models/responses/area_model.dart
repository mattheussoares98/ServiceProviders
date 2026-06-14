import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';

class AreaModel extends AreaEntity implements DataConvertible<AreaEntity> {
  const AreaModel({
    required super.id,
    required super.locationId,
    required super.companyId,
    required super.name,
    super.floor,
    super.description,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory AreaModel.fromEntity(AreaEntity entity) => AreaModel(
    id: entity.id,
    locationId: entity.locationId,
    companyId: entity.companyId,
    name: entity.name,
    floor: entity.floor,
    description: entity.description,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory AreaModel.fromJson(MapDynamic json) => AreaModel(
    id: json['id'] as String? ?? '',
    locationId: json['location_id'] as String? ?? '',
    companyId: json['company_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    floor: json['floor'] as String?,
    description: json['description'] as String?,
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
    'location_id': locationId,
    'company_id': companyId,
    'name': name,
    'floor': floor,
    'description': description,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };

  @override
  AreaEntity toEntity() => AreaEntity(
    id: id,
    locationId: locationId,
    companyId: companyId,
    name: name,
    floor: floor,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
