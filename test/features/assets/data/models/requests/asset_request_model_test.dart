import 'package:clean_architecture/features/assets/data/models/requests/asset_request_model.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeAssetEntity();

  group('AssetRequestModel', () {
    test('should be a subclass of AssetEntity', () {
      final model = AssetRequestModel.fromEntity(tEntity);
      expect(model, isA<AssetEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = AssetRequestModel.fromEntity(tEntity);
      final expected = AssetRequestModel.fromEntity(tEntity);
      expect(model, equals(expected));
    });

    test('should return a valid model fromJson', () {
      final model = AssetRequestModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = AssetRequestModel.fromJson(json);

      expect(result, equals(model));
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = AssetRequestModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to an AssetEntity correctly on toEntity', () {
      final model = AssetRequestModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
