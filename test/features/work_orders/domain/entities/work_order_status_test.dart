import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';

void main() {
  group('WorkOrderStatus.acceptsAttachments', () {
    test('allows attachments only while the work is in progress', () {
      expect(WorkOrderStatus.inProgress.acceptsAttachments, isTrue);
      expect(WorkOrderStatus.open.acceptsAttachments, isFalse);
      expect(WorkOrderStatus.onHold.acceptsAttachments, isFalse);
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

  group('WorkOrderStatus.isClosed', () {
    test('returns true for completed and cancelled, false otherwise', () {
      expect(WorkOrderStatus.completed.isClosed, isTrue);
      expect(WorkOrderStatus.cancelled.isClosed, isTrue);
      expect(WorkOrderStatus.open.isClosed, isFalse);
      expect(WorkOrderStatus.inProgress.isClosed, isFalse);
      expect(WorkOrderStatus.onHold.isClosed, isFalse);
      expect(WorkOrderStatus.pendingConclusionApproval.isClosed, isFalse);
    });
  });
}
