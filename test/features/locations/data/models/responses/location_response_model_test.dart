import 'package:clean_architecture/features/locations/data/models/responses/location_response_model.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeLocationEntity();

  group('LocationResponseModel', () {
    test('should be a subclass of LocationEntity', () {
      final model = LocationResponseModel.fromEntity(tEntity);
      expect(model, isA<LocationEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = LocationResponseModel.fromEntity(tEntity);
      expect(model.id, tEntity.id);
      expect(model.companyId, tEntity.companyId);
      expect(model.name, tEntity.name);
      expect(model.address, tEntity.address);
      expect(model.city, tEntity.city);
      expect(model.state, tEntity.state);
      expect(model.isActive, tEntity.isActive);
      expect(model.createdAt, tEntity.createdAt);
      expect(model.updatedAt, tEntity.updatedAt);
      expect(model.deletedAt, tEntity.deletedAt);
    });

    test('should return a valid model fromJson', () {
      final model = LocationResponseModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = LocationResponseModel.fromJson(json);

      expect(result.id, tEntity.id);
      expect(result.companyId, tEntity.companyId);
      expect(result.name, tEntity.name);
      expect(result.address, tEntity.address);
      expect(result.city, tEntity.city);
      expect(result.state, tEntity.state);
      expect(result.isActive, tEntity.isActive);
      expect(result.createdAt, tEntity.createdAt);
      expect(result.updatedAt, tEntity.updatedAt);
      expect(result.deletedAt, tEntity.deletedAt);
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = LocationResponseModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to a LocationEntity correctly on toEntity', () {
      final model = LocationResponseModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
