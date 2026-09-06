import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/categories/data/models/responses/category_model.dart';
import 'package:o_jogo_da_obra/features/categories/domain/entities/category_entity.dart';

import '../../../../../../testing/mocks/factories/asset_factory.dart';

void main() {
  final tEntity = AssetFactory.makeCategoryEntity();

  group('CategoryModel', () {
    test('should be a subclass of CategoryEntity', () {
      final model = CategoryModel.fromEntity(tEntity);
      expect(model, isA<CategoryEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = CategoryModel.fromEntity(tEntity);
      final expected = CategoryModel.fromEntity(tEntity);
      expect(model, equals(expected));
    });

    test('should return a valid model fromJson', () {
      final model = CategoryModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = CategoryModel.fromJson(json);

      expect(result, equals(model));
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = CategoryModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to a CategoryEntity correctly on toEntity', () {
      final model = CategoryModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
