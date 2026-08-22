import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';

void main() {
  group('WorkOrderStatus.acceptsAttachments', () {
    test('allows attachments while the work is being executed', () {
      expect(WorkOrderStatus.open.acceptsAttachments, isTrue);
      expect(WorkOrderStatus.inProgress.acceptsAttachments, isTrue);
      expect(WorkOrderStatus.onHold.acceptsAttachments, isTrue);
    });

    test('freezes attachments once conclusion is submitted or the order closes', () {
      expect(
        WorkOrderStatus.pendingConclusionApproval.acceptsAttachments,
        isFalse,
      );
      expect(WorkOrderStatus.completed.acceptsAttachments, isFalse);
      expect(WorkOrderStatus.cancelled.acceptsAttachments, isFalse);
    });
  });
}
