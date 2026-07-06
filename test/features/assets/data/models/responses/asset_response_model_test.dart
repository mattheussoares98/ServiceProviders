import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/responses/asset_model.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeAssetEntity();

  group('AssetResponseModel', () {
    test('should be a subclass of AssetEntity', () {
      final model = AssetModel.fromEntity(tEntity);
      expect(model, isA<AssetEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = AssetModel.fromEntity(tEntity);
      final expected = AssetModel.fromEntity(tEntity);
      expect(model, equals(expected));
    });

    test('should return a valid model fromJson', () {
      final model = AssetModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = AssetModel.fromJson(json);

      expect(result, equals(model));
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = AssetModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to an AssetEntity correctly on toEntity', () {
      final model = AssetModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
