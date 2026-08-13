import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';

class AreaRequestModel extends AreaEntity
    implements DataConvertible<AreaEntity> {
  const AreaRequestModel({
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

  factory AreaRequestModel.fromEntity(AreaEntity entity) => AreaRequestModel(
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

  factory AreaRequestModel.fromJson(MapDynamic json) => AreaRequestModel(
    id: json['id'] as String? ?? '',
    locationId: json['location_id'] as String? ?? '',
    companyId: json['company_id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    floor: json['floor'] as String?,
    description: json['description'] as String?,
    createdAt: (json['created_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
  );

  @override
  MapDynamic toJson() => {
    'id': id,
    'location_id': locationId,
    'company_id': companyId,
    'name': name,
    'floor': floor,
    'description': description,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
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
