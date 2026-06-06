import 'package:clean_architecture/features/categories/data/models/requests/category_request_model.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeCategoryEntity();

  group('CategoryRequestModel', () {
    test('should be a subclass of CategoryEntity', () {
      final model = CategoryRequestModel.fromEntity(tEntity);
      expect(model, isA<CategoryEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = CategoryRequestModel.fromEntity(tEntity);
      expect(model.id, tEntity.id);
      expect(model.companyId, tEntity.companyId);
      expect(model.name, tEntity.name);
      expect(model.description, tEntity.description);
      expect(model.color, tEntity.color);
      expect(model.createdAt, tEntity.createdAt);
      expect(model.deletedAt, tEntity.deletedAt);
    });

    test('should return a valid model fromJson', () {
      final model = CategoryRequestModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = CategoryRequestModel.fromJson(json);

      expect(result.id, tEntity.id);
      expect(result.companyId, tEntity.companyId);
      expect(result.name, tEntity.name);
      expect(result.description, tEntity.description);
      expect(result.color, tEntity.color);
      expect(result.createdAt, tEntity.createdAt);
      expect(result.deletedAt, tEntity.deletedAt);
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = CategoryRequestModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to a CategoryEntity correctly on toEntity', () {
      final model = CategoryRequestModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
