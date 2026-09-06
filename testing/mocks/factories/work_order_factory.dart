import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_change_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_entity_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_log_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/audit_logs/audit_metadata_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/change_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/work_order_change_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/change_requests/work_order_change_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_event_type.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_reason_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_request_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pauses/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/task_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_history_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_kpi_metrics_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_observation_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';

import 'factory_helpers.dart';
import 'maintenance_plan_factory.dart';

abstract final class WorkOrderFactory {
  static WorkOrderEntity makeWorkOrderEntity() {
    return WorkOrderEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      assetId: FactoryHelpers.makeId(),
      locationId: FactoryHelpers.makeId(),
      areaId: FactoryHelpers.makeId(),
      assignedToId: FactoryHelpers.makeId(),
      createdById: FactoryHelpers.makeId(),
      maintenancePlanId: FactoryHelpers.makeId(),
      title: FactoryHelpers.makeCompanyName(),
      description: FactoryHelpers.makePhrase(),
      priority: Priority.medium,
      status: WorkOrderStatus.open,
      type: WorkOrderType.corrective,
      scheduledDate: FactoryHelpers.makeDateTime(),
      startedAt: FactoryHelpers.makeDateTime(),
      completedAt: FactoryHelpers.makeDateTime(),
      estimatedDuration: FactoryHelpers.makeInt(120),
      actualDuration: FactoryHelpers.makeInt(90),
      laborCost: FactoryHelpers.makeDouble(),
      partsCost: FactoryHelpers.makeDouble(),
      totalCost: FactoryHelpers.makeDouble(),
      notes: FactoryHelpers.makePhrase(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
      attachments: MaintenancePlanFactory.makeAttachmentEntityList(),
      serviceProviderCompanyId: FactoryHelpers.makeId(),
      providerProfileId: FactoryHelpers.makeId(),
      slaPolicyId: FactoryHelpers.makeId(),
      slaDeadlineAt: FactoryHelpers.makeDateTime(),
      netActiveDuration: FactoryHelpers.makeInt(60),
      completionReason: FactoryHelpers.makePhrase(),
      completionResponsibility: PauseResponsibility.shared,
      completionSectorId: FactoryHelpers.makeId(),
      advanceWarningSentAt: FactoryHelpers.makeDateTime(),
      lastEscalationAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<WorkOrderEntity> makeWorkOrderEntityList() {
    return [
      makeWorkOrderEntity(),
      makeWorkOrderEntity(),
      makeWorkOrderEntity(),
    ];
  }

  static WorkOrderKpiMetricsEntity makeWorkOrderKpiMetricsEntity() {
    return WorkOrderKpiMetricsEntity(
      totalWorkOrders: FactoryHelpers.makeInt(100),
      completedCount: FactoryHelpers.makeInt(50),
      completedWithinSlaCount: FactoryHelpers.makeInt(45),
      slaBreachedCount: FactoryHelpers.makeInt(5),
      deliveryRate: FactoryHelpers.makeDouble() * 100,
      breachRate: FactoryHelpers.makeDouble() * 100,
      mttrMinutes: FactoryHelpers.makeDouble() * 300,
      openCount: FactoryHelpers.makeInt(30),
      inProgressCount: FactoryHelpers.makeInt(15),
      delayedCount: FactoryHelpers.makeInt(5),
      pendingApprovalCount: FactoryHelpers.makeInt(5),
    );
  }

  // Task
  static TaskEntity makeTaskEntity() {
    return TaskEntity(
      id: FactoryHelpers.makeId(),
      workOrderId: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      title: FactoryHelpers.makeWord(),
      description: FactoryHelpers.makePhrase(),
      isCompleted: false,
      sortOrder: FactoryHelpers.makeInt(10),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      completedAt: null,
      completedById: null,
      deletedAt: null,
    );
  }

  static List<TaskEntity> makeTaskEntityList() {
    return [makeTaskEntity(), makeTaskEntity(), makeTaskEntity()];
  }

  // WorkOrderChangeRequest
  static WorkOrderChangeRequestEntity makeWorkOrderChangeRequestEntity() {
    return WorkOrderChangeRequestEntity(
      id: FactoryHelpers.makeId(),
      workOrderId: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      requestedById: FactoryHelpers.makeId(),
      changeType: WorkOrderChangeType.updateNotes,
      changeData: '{"notes": "Updated notes"}',
      status: ChangeRequestStatus.pending,
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
      rejectionReason: null,
      reviewedById: null,
    );
  }

  static List<WorkOrderChangeRequestEntity>
  makeWorkOrderChangeRequestEntityList() {
    return [
      makeWorkOrderChangeRequestEntity(),
      makeWorkOrderChangeRequestEntity(),
      makeWorkOrderChangeRequestEntity(),
    ];
  }

  // WorkOrderHistory
  static WorkOrderHistoryEntity makeWorkOrderHistoryEntity() {
    return WorkOrderHistoryEntity(
      id: FactoryHelpers.makeId(),
      workOrderId: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      userId: FactoryHelpers.makeId(),
      action: 'status_change',
      oldValue: 'open',
      newValue: 'in_progress',
      createdAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<WorkOrderHistoryEntity> makeWorkOrderHistoryEntityList() {
    return [
      makeWorkOrderHistoryEntity(),
      makeWorkOrderHistoryEntity(),
      makeWorkOrderHistoryEntity(),
    ];
  }

  // AuditLog
  static AuditLogEntity makeAuditLogEntity() {
    return AuditLogEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      entityType: AuditEntityType.workOrders,
      entityId: FactoryHelpers.makeId(),
      userId: FactoryHelpers.makeId(),
      action: 'updated',
      summary: FactoryHelpers.makePhrase(),
      changes: [
        AuditChangeEntity(
          field: 'status',
          label: 'Status',
          oldValue: 'open',
          newValue: 'in_progress',
          oldDisplay: 'Aberto',
          newDisplay: 'Em Andamento',
          entityType: AuditEntityType.workOrders,
          entityId: FactoryHelpers.makeId(),
        ),
      ],
      metadata: const AuditMetadataEntity(
        fileName: 'foto_equipamento.png',
        fileUrl: 'https://example.com/foto_equipamento.png',
        fileType: 'image/png',
        fileSizeBytes: 2048,
      ),
      createdAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<AuditLogEntity> makeAuditLogEntityList() {
    return [makeAuditLogEntity(), makeAuditLogEntity(), makeAuditLogEntity()];
  }

  static PauseReasonEntity makePauseReasonEntity() {
    return PauseReasonEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      name: FactoryHelpers.makeCompanyName(),
      isActive: true,
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      deletedAt: null,
    );
  }

  static List<PauseReasonEntity> makePauseReasonEntityList() {
    return [
      makePauseReasonEntity(),
      makePauseReasonEntity(),
      makePauseReasonEntity(),
    ];
  }

  // Pause Request
  static PauseRequestEntity makePauseRequestEntity() {
    return PauseRequestEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      workOrderId: FactoryHelpers.makeId(),
      requestedById: FactoryHelpers.makeId(),
      reasonId: FactoryHelpers.makeId(),
      customReason: FactoryHelpers.makePhrase(),
      observation: FactoryHelpers.makePhrase(),
      responsibility: PauseResponsibility.provider,
      sectorId: FactoryHelpers.makeId(),
      status: PauseRequestStatus.pending,
      pausedAt: FactoryHelpers.makeDateTime(),
      affectsSla: true,
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
      resumedAt: FactoryHelpers.makeDateTime(),
      resumedById: FactoryHelpers.makeId(),
      reviewObservation: FactoryHelpers.makeId(),
      reviewedById: FactoryHelpers.makeId(),
      eventType: PauseEventType
          .values[FactoryHelpers.makeInt(PauseEventType.values.length)],
    );
  }

  static List<PauseRequestEntity> makePauseRequestEntityList() {
    return [
      makePauseRequestEntity(),
      makePauseRequestEntity(),
      makePauseRequestEntity(),
    ];
  }

  // Work Order Observation
  static WorkOrderObservationEntity makeWorkOrderObservationEntity() {
    return WorkOrderObservationEntity(
      id: FactoryHelpers.makeId(),
      companyId: FactoryHelpers.makeId(),
      workOrderId: FactoryHelpers.makeId(),
      authorId: FactoryHelpers.makeId(),
      authorProviderProfileId: null,
      authorName: FactoryHelpers.makePhrase(),
      content: FactoryHelpers.makePhrase(),
      createdAt: FactoryHelpers.makeDateTime(),
      updatedAt: FactoryHelpers.makeDateTime(),
    );
  }

  static List<WorkOrderObservationEntity> makeWorkOrderObservationEntityList() {
    return [
      makeWorkOrderObservationEntity(),
      makeWorkOrderObservationEntity(),
      makeWorkOrderObservationEntity(),
    ];
  }
}
