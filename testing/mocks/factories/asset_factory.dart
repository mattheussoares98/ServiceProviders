import 'package:faker/faker.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_criticality.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/area_entity.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';

import 'factory_helpers.dart';

abstract final class AssetFactory {
  static CategoryEntity makeCategoryEntity() {
    return CategoryEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeCompanyName(),
      description: FactoryHelpers.makePhrase(),
      color: FactoryHelpers.makeString(7),
      createdAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
    );
  }

  static List<CategoryEntity> makeCategoryEntityList() {
    return [makeCategoryEntity(), makeCategoryEntity(), makeCategoryEntity()];
  }

  // Location
  static LocationEntity makeLocationEntity() {
    return LocationEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeCompanyName(),
      address: faker.address.streetAddress(),
      city: faker.address.city(),
      state: faker.address.state(),
      isActive: FactoryHelpers.makeBool(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      complement: FactoryHelpers.makePhrase(),
      number: FactoryHelpers.makeInt(100, min: 1).toString(),
      neighborhood: FactoryHelpers.makeWord(),
      postalCode: FactoryHelpers.makeString(8),
      deletedAt: null,
    );
  }

  static List<LocationEntity> makeLocationEntityList() {
    return [makeLocationEntity(), makeLocationEntity(), makeLocationEntity()];
  }

  // Area
  static AreaEntity makeAreaEntity() {
    return AreaEntity(
      id: FactoryHelpers.makeId(),
      locationId: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeCompanyName(),
      floor: FactoryHelpers.makeInt(10).toString(),
      description: FactoryHelpers.makePhrase(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
    );
  }

  static List<AreaEntity> makeAreaEntityList() {
    return [makeAreaEntity(), makeAreaEntity(), makeAreaEntity()];
  }

  // Asset
  static AssetEntity makeAssetEntity() {
    return AssetEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      areaId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeCompanyName(),
      code: FactoryHelpers.makeString(8),
      manufacturer: FactoryHelpers.makeCompanyName(),
      model: faker.vehicle.model(),
      serialNumber: FactoryHelpers.makeString(12),
      status: AssetStatus.active,
      criticality: AssetCriticality.medium,
      notes: FactoryHelpers.makePhrase(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      categoryId: FactoryHelpers.makeId(),
      warrantyExpiration: FactoryHelpers.makeDateTime(),
      deletedAt: null,
      installDate: FactoryHelpers.makeDateTime(),
      parentAssetId: FactoryHelpers.makeId(),
      revisionForecast: FactoryHelpers.makeDateTime(),
    );
  }

  static List<AssetEntity> makeAssetEntityList() {
    return [makeAssetEntity(), makeAssetEntity(), makeAssetEntity()];
  }
}
