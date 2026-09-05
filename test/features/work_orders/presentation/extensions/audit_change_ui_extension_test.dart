import 'package:flutter_test/flutter_test.dart';
import 'package:o_jogo_da_obra/features/assets/domain/entities/asset_status.dart';
import 'package:o_jogo_da_obra/features/assets/presentation/pages/create_update_asset/widgets/extensions.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_change_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_entity_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_log_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/audit_change_ui_extension.dart';
import 'package:o_jogo_da_obra/features/work_orders/presentation/extensions/work_order_extensions.dart';

void main() {
  group('AuditEntityType', () {
    test('provides human-readable labels in Portuguese', () {
      expect(AuditEntityType.workOrders.label, equals('Ordens de serviço'));
      expect(AuditEntityType.tasks.label, equals('Tarefas'));
      expect(AuditEntityType.assets.label, equals('Ativos'));
      expect(AuditEntityType.attachments.label, equals('Anexos'));
      expect(AuditEntityType.unknown.label, equals('Registro'));
    });
  });

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

    test('formats booleans and other enums (pause, checklist, file_type, content)', () {
      const boolChange = AuditChangeEntity(
        field: 'is_required',
        oldValue: 'false',
        newValue: 'true',
      );
      expect(boolChange.localizedLabel, equals('Obrigatório'));
      expect(boolChange.localizedOldValue, equals('Não'));
      expect(boolChange.localizedNewValue, equals('Sim'));

      const contentChange = AuditChangeEntity(
        field: 'content',
        oldValue: 'Observação antiga',
        newValue: 'Observação nova',
      );
      expect(contentChange.localizedLabel, equals('Observação'));
      expect(contentChange.localizedOldValue, equals('Observação antiga'));
      expect(contentChange.localizedNewValue, equals('Observação nova'));

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

  group('AuditLogUiExtension', () {
    test('returns summary when present', () {
      final log = AuditLogEntity(
        id: '1',
        companyId: 'comp-1',
        entityType: AuditEntityType.workOrders,
        entityId: 'wo-1',
        action: 'updated',
        summary: 'Pausa solicitada',
        createdAt: DateTime(2026, 9, 3),
      );

      expect(log.displayTitle, equals('Pausa solicitada'));
    });

    test(
      'generates formatted title from entityType and action when summary is null',
      () {
        final updatedLog = AuditLogEntity(
          id: '1',
          companyId: 'comp-1',
          entityType: AuditEntityType.tasks,
          entityId: 't-1',
          action: 'updated',
          createdAt: DateTime(2026, 9, 3),
        );
        expect(updatedLog.displayTitle, equals('Alteração - TAREFAS'));

        final createdLog = AuditLogEntity(
          id: '2',
          companyId: 'comp-1',
          entityType: AuditEntityType.workOrders,
          entityId: 'wo-1',
          action: 'created',
          createdAt: DateTime(2026, 9, 3),
        );
        expect(createdLog.displayTitle, equals('Criação - ORDENS DE SERVIÇO'));

        final deletedLog = AuditLogEntity(
          id: '3',
          companyId: 'comp-1',
          entityType: AuditEntityType.assets,
          entityId: 'a-1',
          action: 'deleted',
          createdAt: DateTime(2026, 9, 3),
        );
        expect(deletedLog.displayTitle, equals('Exclusão - ATIVOS'));

        final restoredLog = AuditLogEntity(
          id: '4',
          companyId: 'comp-1',
          entityType: AuditEntityType.attachments,
          entityId: 'att-1',
          action: 'restored',
          createdAt: DateTime(2026, 9, 3),
        );
        expect(restoredLog.displayTitle, equals('Restauração - ANEXOS'));

        final createdObsLog = AuditLogEntity(
          id: '5',
          companyId: 'comp-1',
          entityType: AuditEntityType.workOrderObservations,
          entityId: 'obs-1',
          action: 'created',
          createdAt: DateTime(2026, 9, 3),
        );
        expect(createdObsLog.displayTitle, equals('Observação adicionada'));

        final deletedObsLog = AuditLogEntity(
          id: '6',
          companyId: 'comp-1',
          entityType: AuditEntityType.workOrderObservations,
          entityId: 'obs-2',
          action: 'deleted',
          createdAt: DateTime(2026, 9, 3),
        );
        expect(deletedObsLog.displayTitle, equals('Observação removida'));
      },
    );
  });
}
