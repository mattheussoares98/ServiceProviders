import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/value_objects/work_order_filter.dart';

void main() {
  group('WorkOrderFilter', () {
    test('defaults isDelayed and onlyDeleted to false', () {
      const filter = WorkOrderFilter();

      expect(filter.isDelayed, isFalse);
      expect(filter.onlyDeleted, isFalse);
      expect(filter.isEmpty, isTrue);
      expect(filter.activeCount, 0);
    });

    test('isDelayed affects isEmpty and activeCount', () {
      const filter = WorkOrderFilter(isDelayed: true);

      expect(filter.isDelayed, isTrue);
      expect(filter.isEmpty, isFalse);
      expect(filter.activeCount, 1);
    });

    test('onlyDeleted affects isEmpty and activeCount', () {
      const filter = WorkOrderFilter(onlyDeleted: true);

      expect(filter.onlyDeleted, isTrue);
      expect(filter.isEmpty, isFalse);
      expect(filter.activeCount, 1);
    });

    test('copyWith updates isDelayed, onlyDeleted, and other properties', () {
      const filter = WorkOrderFilter();
      final updated = filter.copyWith(
        isDelayed: true,
        onlyDeleted: true,
        statuses: [WorkOrderStatus.open],
      );

      expect(updated.isDelayed, isTrue);
      expect(updated.onlyDeleted, isTrue);
      expect(updated.statuses, [WorkOrderStatus.open]);
      expect(updated.activeCount, 3);
    });
  });
}
