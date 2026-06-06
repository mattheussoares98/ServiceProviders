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
}
