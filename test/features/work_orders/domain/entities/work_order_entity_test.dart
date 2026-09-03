import 'package:flutter_test/flutter_test.dart';

import '../../../../../testing/mocks/entity_factory.dart';

void main() {
  group('WorkOrderEntity', () {
    test(
      'isDeleted returns true when deletedAt is not null and false otherwise',
      () {
        final active = EntityFactory.makeWorkOrderEntity().copyWith(
          annulDeletedAt: true,
        );
        final deleted = EntityFactory.makeWorkOrderEntity().copyWith(
          deletedAt: DateTime.now(),
        );

        expect(active.isDeleted, isFalse);
        expect(deleted.isDeleted, isTrue);
      },
    );
  });
}
