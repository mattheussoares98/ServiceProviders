import 'package:clean_architecture/features/locations/data/models/requests/area_request_model.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeAreaEntity();

  group('AreaRequestModel', () {
    test('should be a subclass of AreaEntity', () {
      final model = AreaRequestModel.fromEntity(tEntity);
      expect(model, isA<AreaEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = AreaRequestModel.fromEntity(tEntity);
      expect(model.id, tEntity.id);
      expect(model.locationId, tEntity.locationId);
      expect(model.companyId, tEntity.companyId);
      expect(model.name, tEntity.name);
      expect(model.floor, tEntity.floor);
      expect(model.description, tEntity.description);
      expect(model.createdAt, tEntity.createdAt);
      expect(model.updatedAt, tEntity.updatedAt);
      expect(model.deletedAt, tEntity.deletedAt);
    });

    test('should return a valid model fromJson', () {
      final model = AreaRequestModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = AreaRequestModel.fromJson(json);

      expect(result.id, tEntity.id);
      expect(result.locationId, tEntity.locationId);
      expect(result.companyId, tEntity.companyId);
      expect(result.name, tEntity.name);
      expect(result.floor, tEntity.floor);
      expect(result.description, tEntity.description);
      expect(result.createdAt, tEntity.createdAt);
      expect(result.updatedAt, tEntity.updatedAt);
      expect(result.deletedAt, tEntity.deletedAt);
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = AreaRequestModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to an AreaEntity correctly on toEntity', () {
      final model = AreaRequestModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
