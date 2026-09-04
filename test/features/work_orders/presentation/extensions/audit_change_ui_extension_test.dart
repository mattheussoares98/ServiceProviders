import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_change_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_entity_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/audit_change_ui_extension.dart';

void main() {
  group('AuditChangeUiExtension', () {
    test('formats work order status and field label', () {
      const change = AuditChangeEntity(
        field: 'status',
        oldValue: 'open',
        newValue: 'in_progress',
        oldDisplay: 'open',
        newDisplay: 'in_progress',
      );

      expect(change.localizedLabel, equals('Status'));
      expect(change.localizedOldValue, equals(WorkOrderStatus.open.label));
      expect(
        change.localizedNewValue,
        equals(WorkOrderStatus.inProgress.label),
      );
    });

    test('formats asset status when entityType is assets', () {
      const change = AuditChangeEntity(
        field: 'status',
        oldValue: 'active',
        newValue: 'decommissioned',
        entityType: AuditEntityType.assets,
      );

      expect(change.localizedOldValue, equals(AssetStatus.active.label));
      expect(
        change.localizedNewValue,
        equals(AssetStatus.decommissioned.label),
      );
    });

    test('formats priority and type', () {
      const change = AuditChangeEntity(
        field: 'priority',
        oldValue: 'low',
        newValue: 'critical',
      );
      expect(change.localizedLabel, equals('Prioridade'));
      expect(change.localizedOldValue, equals(Priority.low.label));
      expect(change.localizedNewValue, equals(Priority.critical.label));

      const typeChange = AuditChangeEntity(
        field: 'type',
        oldValue: 'corrective',
        newValue: 'preventive',
      );
      expect(typeChange.localizedLabel, equals('Tipo'));
      expect(
        typeChange.localizedOldValue,
        equals(WorkOrderType.corrective.label),
      );
      expect(
        typeChange.localizedNewValue,
        equals(WorkOrderType.preventive.label),
      );
    });

    test('formats booleans and other enums (pause, checklist, file_type)', () {
      const boolChange = AuditChangeEntity(
        field: 'is_required',
        oldValue: 'false',
        newValue: 'true',
      );
      expect(boolChange.localizedLabel, equals('Obrigatório'));
      expect(boolChange.localizedOldValue, equals('Não'));
      expect(boolChange.localizedNewValue, equals('Sim'));

      const pauseChange = AuditChangeEntity(
        field: 'status',
        oldValue: 'pending',
        newValue: 'approved',
        entityType: AuditEntityType.workOrderPauseRequests,
      );
      expect(
        pauseChange.localizedOldValue,
        equals(PauseRequestStatus.pending.label),
      );
      expect(
        pauseChange.localizedNewValue,
        equals(PauseRequestStatus.approved.label),
      );
    });

    test('returns null when values are null', () {
      const change = AuditChangeEntity(field: 'status');

      expect(change.localizedOldValue, isNull);
      expect(change.localizedNewValue, isNull);
    });

    test('correctly identifies displayable and non-displayable fields', () {
      const displayableField = AuditChangeEntity(field: 'status');
      const dueDateField = AuditChangeEntity(field: 'due_date');
      const completedAtField = AuditChangeEntity(field: 'completed_at');
      const updatedAtField = AuditChangeEntity(field: 'updated_at');
      const startedAtField = AuditChangeEntity(field: 'started_at');

      expect(displayableField.isDisplayable, isTrue);
      expect(dueDateField.isDisplayable, isTrue);
      expect(completedAtField.isDisplayable, isFalse);
      expect(updatedAtField.isDisplayable, isFalse);
      expect(startedAtField.isDisplayable, isFalse);
    });
  });
}
