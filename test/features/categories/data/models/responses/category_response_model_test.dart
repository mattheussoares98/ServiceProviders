import 'package:clean_architecture/features/categories/data/models/responses/category_response_model.dart';
import 'package:clean_architecture/features/categories/domain/entities/category_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeCategoryEntity();

  group('CategoryResponseModel', () {
    test('should be a subclass of CategoryEntity', () {
      final model = CategoryResponseModel.fromEntity(tEntity);
      expect(model, isA<CategoryEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = CategoryResponseModel.fromEntity(tEntity);
      final expected = CategoryResponseModel.fromEntity(tEntity);
      expect(model, equals(expected));
    });

    test('should return a valid model fromJson', () {
      final model = CategoryResponseModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = CategoryResponseModel.fromJson(json);

      expect(result, equals(model));
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = CategoryResponseModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to a CategoryEntity correctly on toEntity', () {
      final model = CategoryResponseModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
