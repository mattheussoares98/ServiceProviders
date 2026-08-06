import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/attachments/data/models/responses/attachment_response_model.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';

class WorkOrderResponseModel extends WorkOrderEntity
    implements DataConvertible<WorkOrderEntity> {
  const WorkOrderResponseModel({
    required super.id,
    required super.companyId,
    required super.assetId,
    required super.locationId,
    required super.areaId,
    required super.assignedToId,
    required super.createdById,
    required super.maintenancePlanId,
    required super.title,
    required super.description,
    required super.priority,
    required super.status,
    required super.type,
    required super.scheduledDate,
    required super.startedAt,
    required super.completedAt,
    required super.estimatedDuration,
    required super.actualDuration,
    required super.laborCost,
    required super.partsCost,
    required super.totalCost,
    required super.notes,
    required super.createdAt,
    required super.updatedAt,
    required super.deletedAt,
    super.attachments,
    required super.serviceProviderCompanyId,
    required super.providerProfileId,
    super.openedBy,
    required super.slaPolicyId,
    required super.slaDeadlineAt,
    super.slaBreached,
    required super.netActiveDuration,
    required super.completionReason,
    required super.completionResponsibility,
    required super.completionSectorId,
  });

  factory WorkOrderResponseModel.fromEntity(WorkOrderEntity entity) =>
      WorkOrderResponseModel(
        id: entity.id,
        companyId: entity.companyId,
        assetId: entity.assetId,
        locationId: entity.locationId,
        areaId: entity.areaId,
        assignedToId: entity.assignedToId,
        createdById: entity.createdById,
        maintenancePlanId: entity.maintenancePlanId,
        title: entity.title,
        description: entity.description,
        priority: entity.priority,
        status: entity.status,
        type: entity.type,
        scheduledDate: entity.scheduledDate,
        startedAt: entity.startedAt,
        completedAt: entity.completedAt,
        estimatedDuration: entity.estimatedDuration,
        actualDuration: entity.actualDuration,
        laborCost: entity.laborCost,
        partsCost: entity.partsCost,
        totalCost: entity.totalCost,
        notes: entity.notes,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
        deletedAt: entity.deletedAt,
        attachments: entity.attachments,
        serviceProviderCompanyId: entity.serviceProviderCompanyId,
        providerProfileId: entity.providerProfileId,
        slaPolicyId: entity.slaPolicyId,
        slaDeadlineAt: entity.slaDeadlineAt,
        slaBreached: entity.slaBreached,
        netActiveDuration: entity.netActiveDuration,
        openedBy: entity.openedBy,
        completionReason: entity.completionReason,
        completionResponsibility: entity.completionResponsibility,
        completionSectorId: entity.completionSectorId,
      );

  factory WorkOrderResponseModel.fromJson(MapDynamic json) =>
      WorkOrderResponseModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        assetId: json['asset_id'] as String?,
        locationId: json['location_id'] as String? ?? '',
        areaId: json['area_id'] as String?,
        assignedToId: json['assigned_to_id'] as String?,
        createdById: json['created_by_id'] as String? ?? '',
        maintenancePlanId: json['maintenance_plan_id'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        priority: Priority.fromCode(json['priority'] as String? ?? 'medium'),
        status: WorkOrderStatus.fromCode(json['status'] as String? ?? 'open'),
        type: WorkOrderType.fromCode(json['type'] as String? ?? 'corrective'),
        scheduledDate: json['scheduled_date'] != null
            ? DateTime.parse(json['scheduled_date'] as String)
            : null,
        startedAt: json['started_at'] != null
            ? DateTime.parse(json['started_at'] as String)
            : null,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        estimatedDuration: json['estimated_duration'] as int?,
        actualDuration: json['actual_duration'] as int?,
        laborCost: (json['labor_cost'] as num?)?.toDouble(),
        partsCost: (json['parts_cost'] as num?)?.toDouble(),
        totalCost: (json['total_cost'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
        attachments:
            (json['attachments'] as List?)
                ?.map((e) => AttachmentResponseModel.fromJson(e as MapDynamic))
                .where((e) => e.deletedAt == null)
                .toList() ??
            const [],
        serviceProviderCompanyId:
            json['service_provider_company_id'] as String?,
        providerProfileId: json['provider_profile_id'] as String?,
        slaPolicyId: json['sla_policy_id'] as String?,
        slaDeadlineAt: json['sla_deadline_at'] != null
            ? DateTime.parse(json['sla_deadline_at'] as String)
            : null,
        slaBreached: json['sla_breached'] as bool? ?? false,
        netActiveDuration: json['net_active_duration'] as int?,
        openedBy:
            AppMode.fromName(json['opened_by'] as String?) ?? AppMode.internal,
        completionReason: json['completion_reason'] as String?,
        completionResponsibility: json['completion_responsibility'] != null
            ? PauseResponsibility.fromValue(
                json['completion_responsibility'] as String,
              )
            : null,
        completionSectorId: json['completion_sector_id'] as String?,
      );

  @override
  MapDynamic toJson() => {
    'id': id,
    'company_id': companyId,
    'asset_id': assetId,
    'location_id': locationId,
    'area_id': areaId,
    'assigned_to_id': assignedToId,
    'created_by_id': createdById,
    'maintenance_plan_id': maintenancePlanId,
    'title': title,
    'description': description,
    'priority': priority.code,
    'status': status.code,
    'type': type.code,
    'scheduled_date': scheduledDate?.toUtc().toIso8601String(),
    'started_at': startedAt?.toUtc().toIso8601String(),
    'completed_at': completedAt?.toUtc().toIso8601String(),
    'estimated_duration': estimatedDuration,
    'actual_duration': actualDuration,
    'labor_cost': laborCost,
    'parts_cost': partsCost,
    'total_cost': totalCost,
    'notes': notes,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
    'service_provider_company_id': serviceProviderCompanyId,
    'provider_profile_id': providerProfileId,
    'sla_policy_id': slaPolicyId,
    'sla_deadline_at': slaDeadlineAt?.toUtc().toIso8601String(),
    'sla_breached': slaBreached,
    'net_active_duration': netActiveDuration,
    'opened_by': openedBy.name,
    'completion_reason': completionReason,
    'completion_responsibility': completionResponsibility?.value,
    'completion_sector_id': completionSectorId,
  };

  @override
  WorkOrderEntity toEntity() => WorkOrderEntity(
    id: id,
    companyId: companyId,
    assetId: assetId,
    locationId: locationId,
    areaId: areaId,
    assignedToId: assignedToId,
    createdById: createdById,
    maintenancePlanId: maintenancePlanId,
    title: title,
    description: description,
    priority: priority,
    status: status,
    type: type,
    scheduledDate: scheduledDate,
    startedAt: startedAt,
    completedAt: completedAt,
    estimatedDuration: estimatedDuration,
    actualDuration: actualDuration,
    laborCost: laborCost,
    partsCost: partsCost,
    totalCost: totalCost,
    notes: notes,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    attachments: attachments,
    serviceProviderCompanyId: serviceProviderCompanyId,
    providerProfileId: providerProfileId,
    slaPolicyId: slaPolicyId,
    slaDeadlineAt: slaDeadlineAt,
    slaBreached: slaBreached,
    netActiveDuration: netActiveDuration,
    openedBy: openedBy,
    completionReason: completionReason,
    completionResponsibility: completionResponsibility,
    completionSectorId: completionSectorId,
  );
}
