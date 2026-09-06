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
  });
}
