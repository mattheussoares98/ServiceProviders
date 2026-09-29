import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/assets/data/models/responses/asset_model.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_entity.dart';

import '../../../../../../testing/mocks/factories/asset_factory.dart';

void main() {
  final tEntity = AssetFactory.makeAssetEntity();

  group('AssetModel', () {
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

    test('should correctly parse and serialize location_id, customer_id, and nullable area_id', () {
      final json = {
        'id': 'asset-1',
        'company_id': 'comp-1',
        'location_id': 'loc-1',
        'area_id': null,
        'customer_id': 'cust-1',
        'name': 'Pump A',
        'status': 'active',
        'criticality': 'high',
        'created_at': DateTime.utc(2026).toIso8601String(),
        'updated_at': DateTime.utc(2026, 1, 2).toIso8601String(),
      };

      final model = AssetModel.fromJson(json);
      expect(model.locationId, equals('loc-1'));
      expect(model.areaId, isNull);
      expect(model.customerId, equals('cust-1'));

      final serialized = model.toJson();
      expect(serialized['location_id'], equals('loc-1'));
      expect(serialized['area_id'], isNull);
      expect(serialized['customer_id'], equals('cust-1'));
    });
  });
}
