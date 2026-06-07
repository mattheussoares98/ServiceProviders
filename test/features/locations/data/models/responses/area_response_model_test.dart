import 'package:clean_architecture/features/locations/data/models/responses/area_response_model.dart';
import 'package:clean_architecture/features/locations/domain/entities/area_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../testing/mocks/entity_factory.dart';

void main() {
  final tEntity = EntityFactory.makeAreaEntity();

  group('AreaResponseModel', () {
    test('should be a subclass of AreaEntity', () {
      final model = AreaResponseModel.fromEntity(tEntity);
      expect(model, isA<AreaEntity>());
    });

    test('should return a valid model fromEntity', () {
      final model = AreaResponseModel.fromEntity(tEntity);
      final expected = AreaResponseModel.fromEntity(tEntity);
      expect(model, equals(expected));
    });

    test('should return a valid model fromJson', () {
      final model = AreaResponseModel.fromEntity(tEntity);
      final json = model.toJson();

      final result = AreaResponseModel.fromJson(json);

      expect(result, equals(model));
    });

    test('should return a MapDynamic containing the proper data on toJson', () {
      final model = AreaResponseModel.fromEntity(tEntity);
      final expectedJson = model.toJson();

      final result = model.toJson();

      expect(result, expectedJson);
    });

    test('should convert to an AreaEntity correctly on toEntity', () {
      final model = AreaResponseModel.fromEntity(tEntity);
      final entity = model.toEntity();
      expect(entity, tEntity);
    });
  });
}
