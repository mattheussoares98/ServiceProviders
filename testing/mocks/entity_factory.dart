import 'package:clean_architecture/features/assets/domain/entities/asset_criticality.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_status.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:faker/faker.dart';

abstract final class EntityFactory {
  // Category
  static CategoryEntity makeCategoryEntity({
    String? id,
    String? companyId,
    String? name,
    String? description,
    String? color,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return CategoryEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      name: name ?? faker.company.name(),
      description: description ?? faker.lorem.sentence(),
      color: color ?? faker.randomGenerator.string(7),
      createdAt: createdAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<CategoryEntity> makeCategoryEntityList() {
    return [
      makeCategoryEntity(),
      makeCategoryEntity(),
      makeCategoryEntity(),
    ];
  }

  // Location
  static LocationEntity makeLocationEntity({
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
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      name: name ?? faker.company.name(),
      address: address ?? faker.address.streetAddress(),
      city: city ?? faker.address.city(),
      state: state ?? faker.address.state(),
      isActive: isActive ?? faker.randomGenerator.boolean(),
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<LocationEntity> makeLocationEntityList() {
    return [
      makeLocationEntity(),
      makeLocationEntity(),
      makeLocationEntity(),
    ];
  }

  // Area
  static AreaEntity makeAreaEntity({
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
      id: id ?? faker.guid.guid(),
      locationId: locationId ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      name: name ?? faker.company.name(),
      floor: floor ?? faker.randomGenerator.integer(10).toString(),
      description: description ?? faker.lorem.sentence(),
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<AreaEntity> makeAreaEntityList() {
    return [
      makeAreaEntity(),
      makeAreaEntity(),
      makeAreaEntity(),
    ];
  }

  // Asset
  static AssetEntity makeAssetEntity({
    String? id,
    String? companyId,
    String? areaId,
    String? categoryId,
    String? parentAssetId,
    String? name,
    String? code,
    String? manufacturer,
    String? model,
    String? serialNumber,
    DateTime? installDate,
    DateTime? warrantyExpiration,
    DateTime? revisionForecast,
    AssetStatus? status,
    AssetCriticality? criticality,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AssetEntity(
      id: id ?? faker.guid.guid(),
      companyId: companyId ?? faker.guid.guid(),
      areaId: areaId ?? faker.guid.guid(),
      categoryId: categoryId,
      parentAssetId: parentAssetId,
      name: name ?? faker.company.name(),
      code: code ?? faker.randomGenerator.string(8),
      manufacturer: manufacturer ?? faker.company.name(),
      model: model ?? faker.vehicle.model(),
      serialNumber: serialNumber ?? faker.randomGenerator.string(12),
      installDate: installDate ?? faker.date.dateTime(),
      warrantyExpiration: warrantyExpiration ?? faker.date.dateTime(),
      revisionForecast: revisionForecast ?? faker.date.dateTime(),
      status: status ?? AssetStatus.active,
      criticality: criticality ?? AssetCriticality.medium,
      notes: notes ?? faker.lorem.sentence(),
      createdAt: createdAt ?? faker.date.dateTime(),
      updatedAt: updatedAt ?? faker.date.dateTime(),
      deletedAt: deletedAt,
    );
  }

  static List<AssetEntity> makeAssetEntityList() {
    return [
      makeAssetEntity(),
      makeAssetEntity(),
      makeAssetEntity(),
    ];
  }
}
