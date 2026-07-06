import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/locations/data/models/responses/location_model.dart';
import 'package:o_jogo_da_obra/features/locations/domain/entities/location_entity.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeLocationEntity();

  group('LocationResponseModel', () {
    test('should be a subclass of LocationEntity', () {
      final model = LocationModel.fromEntity(tEntity);
      expect(model, isA<LocationEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = LocationModel.fromEntity(tEntity);
      final expected = LocationModel.fromEntity(tEntity);
      expect(model, equals(expected));
    });

    test('should return a valid model fromJson', () {
      final model = LocationModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = LocationModel.fromJson(json);

      expect(result, equals(model));
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = LocationModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to a LocationEntity correctly on toEntity', () {
      final model = LocationModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
