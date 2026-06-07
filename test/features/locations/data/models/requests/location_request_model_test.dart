import 'package:clean_architecture/features/locations/data/models/requests/location_request_model.dart';
import 'package:clean_architecture/features/locations/domain/entities/location_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeLocationEntity();

  group('LocationRequestModel', () {
    test('should be a subclass of LocationEntity', () {
      final model = LocationRequestModel.fromEntity(tEntity);
      expect(model, isA<LocationEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = LocationRequestModel.fromEntity(tEntity);
      final expected = LocationRequestModel.fromEntity(tEntity);
      expect(model, equals(expected));
    });

    test('should return a valid model fromJson', () {
      final model = LocationRequestModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = LocationRequestModel.fromJson(json);

      expect(result, equals(model));
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = LocationRequestModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to a LocationEntity correctly on toEntity', () {
      final model = LocationRequestModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
