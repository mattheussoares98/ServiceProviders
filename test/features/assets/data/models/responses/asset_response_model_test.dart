import 'package:clean_architecture/features/assets/data/models/responses/asset_response_model.dart';
import 'package:clean_architecture/features/assets/domain/entities/asset_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeAssetEntity();

  group('AssetResponseModel', () {
    test('should be a subclass of AssetEntity', () {
      final model = AssetResponseModel.fromEntity(tEntity);
      expect(model, isA<AssetEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = AssetResponseModel.fromEntity(tEntity);
      expect(model.id, tEntity.id);
      expect(model.companyId, tEntity.companyId);
      expect(model.areaId, tEntity.areaId);
      expect(model.categoryId, tEntity.categoryId);
      expect(model.parentAssetId, tEntity.parentAssetId);
      expect(model.name, tEntity.name);
      expect(model.code, tEntity.code);
      expect(model.manufacturer, tEntity.manufacturer);
      expect(model.model, tEntity.model);
      expect(model.serialNumber, tEntity.serialNumber);
      expect(model.installDate, tEntity.installDate);
      expect(model.warrantyExpiration, tEntity.warrantyExpiration);
      expect(model.revisionForecast, tEntity.revisionForecast);
      expect(model.status, tEntity.status);
      expect(model.criticality, tEntity.criticality);
      expect(model.notes, tEntity.notes);
      expect(model.createdAt, tEntity.createdAt);
      expect(model.updatedAt, tEntity.updatedAt);
      expect(model.deletedAt, tEntity.deletedAt);
    });

    test('should return a valid model fromJson', () {
      final model = AssetResponseModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = AssetResponseModel.fromJson(json);

      expect(result.id, tEntity.id);
      expect(result.companyId, tEntity.companyId);
      expect(result.areaId, tEntity.areaId);
      expect(result.categoryId, tEntity.categoryId);
      expect(result.parentAssetId, tEntity.parentAssetId);
      expect(result.name, tEntity.name);
      expect(result.code, tEntity.code);
      expect(result.manufacturer, tEntity.manufacturer);
      expect(result.model, tEntity.model);
      expect(result.serialNumber, tEntity.serialNumber);
      expect(result.installDate, tEntity.installDate);
      expect(result.warrantyExpiration, tEntity.warrantyExpiration);
      expect(result.revisionForecast, tEntity.revisionForecast);
      expect(result.status, tEntity.status);
      expect(result.criticality, tEntity.criticality);
      expect(result.notes, tEntity.notes);
      expect(result.createdAt, tEntity.createdAt);
      expect(result.updatedAt, tEntity.updatedAt);
      expect(result.deletedAt, tEntity.deletedAt);
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = AssetResponseModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to an AssetEntity correctly on toEntity', () {
      final model = AssetResponseModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
