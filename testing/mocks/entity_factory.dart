import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:faker/faker.dart';

abstract final class EntityFactory {
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
}
