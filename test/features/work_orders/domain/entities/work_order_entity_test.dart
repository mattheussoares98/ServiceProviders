import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/factories/work_order_factory.dart';

void main() {
  group('WorkOrderEntity', () {
    test(
      'isDeleted returns true when deletedAt is not null and false otherwise',
      () {
        final active = WorkOrderFactory.makeWorkOrderEntity().copyWith(
          annulDeletedAt: true,
        );
        final deleted = WorkOrderFactory.makeWorkOrderEntity().copyWith(
          deletedAt: DateTime.now(),
        );

        expect(active.isDeleted, isFalse);
        expect(deleted.isDeleted, isTrue);
      },
    );

    test('supports customerId and nullable locationId', () {
      final orderWithCustomer = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        customerId: 'cust-123',
        annulLocationId: true,
      );

      expect(orderWithCustomer.customerId, equals('cust-123'));
      expect(orderWithCustomer.locationId, isNull);
      expect(orderWithCustomer.props, contains('cust-123'));
    });

    test('copyWith updates or annuls customerId and locationId correctly', () {
      final base = WorkOrderFactory.makeWorkOrderEntity().copyWith(
        locationId: 'loc-1',
        customerId: 'cust-1',
      );

      final updated = base.copyWith(
        locationId: 'loc-2',
        customerId: 'cust-2',
      );
      expect(updated.locationId, equals('loc-2'));
      expect(updated.customerId, equals('cust-2'));

      final annulled = updated.copyWith(
        annulLocationId: true,
        annulCustomerId: true,
      );
      expect(annulled.locationId, isNull);
      expect(annulled.customerId, isNull);
    });
  });
}

