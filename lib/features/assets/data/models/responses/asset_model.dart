import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';

class AssetModel extends AssetEntity implements DataConvertible<AssetEntity> {
  const AssetModel({
    required super.id,
    required super.companyId,
    required super.areaId,
    super.categoryId,
    super.parentAssetId,
    required super.name,
    super.code,
    super.manufacturer,
    super.model,
    super.serialNumber,
    super.installDate,
    super.warrantyExpiration,
    super.revisionForecast,
    required super.status,
    required super.criticality,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory AssetModel.fromEntity(AssetEntity entity) => AssetModel(
    id: entity.id,
    companyId: entity.companyId,
    areaId: entity.areaId,
    categoryId: entity.categoryId,
    parentAssetId: entity.parentAssetId,
    name: entity.name,
    code: entity.code,
    manufacturer: entity.manufacturer,
    model: entity.model,
    serialNumber: entity.serialNumber,
    installDate: entity.installDate,
    warrantyExpiration: entity.warrantyExpiration,
    revisionForecast: entity.revisionForecast,
    status: entity.status,
    criticality: entity.criticality,
    notes: entity.notes,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory AssetModel.fromJson(MapDynamic json) => AssetModel(
    id: json['id'] as String? ?? '',
    companyId: json['company_id'] as String? ?? '',
    areaId: json['area_id'] as String? ?? '',
    categoryId: json['category_id'] as String?,
    parentAssetId: json['parent_asset_id'] as String?,
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    manufacturer: json['manufacturer'] as String?,
    model: json['model'] as String?,
    serialNumber: json['serial_number'] as String?,
    installDate: json['install_date'] != null
        ? DateTime.parse(json['install_date'] as String)
        : null,
    warrantyExpiration: json['warranty_expiration'] != null
        ? DateTime.parse(json['warranty_expiration'] as String)
        : null,
    revisionForecast: json['revision_forecast'] != null
        ? DateTime.parse(json['revision_forecast'] as String)
        : null,
    status: AssetStatus.fromCode(json['status'] as String? ?? 'active'),
    criticality: AssetCriticality.fromCode(
      json['criticality'] as String? ?? 'medium',
    ),
    notes: json['notes'] as String?,
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
    'area_id': areaId,
    'category_id': categoryId,
    'parent_asset_id': parentAssetId,
    'name': name,
    'code': code,
    'manufacturer': manufacturer,
    'model': model,
    'serial_number': serialNumber,
    'install_date': installDate?.toIso8601String(),
    'warranty_expiration': warrantyExpiration?.toIso8601String(),
    'revision_forecast': revisionForecast?.toIso8601String(),
    'status': status.code,
    'criticality': criticality.code,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };

  @override
  AssetEntity toEntity() => AssetEntity(
    id: id,
    companyId: companyId,
    areaId: areaId,
    categoryId: categoryId,
    parentAssetId: parentAssetId,
    name: name,
    code: code,
    manufacturer: manufacturer,
    model: model,
    serialNumber: serialNumber,
    installDate: installDate,
    warrantyExpiration: warrantyExpiration,
    revisionForecast: revisionForecast,
    status: status,
    criticality: criticality,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
