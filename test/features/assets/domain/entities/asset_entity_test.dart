import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/factories/asset_factory.dart';

void main() {
  group('AssetEntity', () {
    test(
      'isDeleted returns true when deletedAt is not null and false otherwise',
      () {
        final active = AssetFactory.makeAssetEntity().copyWith(
          annulDeletedAt: true,
        );
        final deleted = AssetFactory.makeAssetEntity().copyWith(
          deletedAt: DateTime.now(),
        );

        expect(active.isDeleted, isFalse);
        expect(deleted.isDeleted, isTrue);
      },
    );

    test('supports locationId, customerId, and nullable areaId', () {
      final asset = AssetFactory.makeAssetEntity().copyWith(
        locationId: 'loc-123',
        customerId: 'cust-456',
        annulAreaId: true,
      );

      expect(asset.locationId, equals('loc-123'));
      expect(asset.customerId, equals('cust-456'));
      expect(asset.areaId, isNull);
      expect(asset.props, contains('loc-123'));
      expect(asset.props, contains('cust-456'));
    });

    test(
      'copyWith updates or annuls locationId, areaId, and customerId correctly',
      () {
        final base = AssetFactory.makeAssetEntity().copyWith(
          locationId: 'loc-1',
          areaId: 'area-1',
          customerId: 'cust-1',
        );

        final updated = base.copyWith(
          locationId: 'loc-2',
          areaId: 'area-2',
          customerId: 'cust-2',
        );
        expect(updated.locationId, equals('loc-2'));
        expect(updated.areaId, equals('area-2'));
        expect(updated.customerId, equals('cust-2'));

        final annulled = updated.copyWith(
          annulLocationId: true,
          annulAreaId: true,
          annulCustomerId: true,
        );
        expect(annulled.locationId, isNull);
        expect(annulled.areaId, isNull);
        expect(annulled.customerId, isNull);
      },
    );
  });
}
