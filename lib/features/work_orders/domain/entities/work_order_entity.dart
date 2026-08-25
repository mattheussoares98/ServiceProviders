import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/auth/domain/entities/app_mode.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/pause_responsability.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';

class WorkOrderEntity extends Equatable {
  const WorkOrderEntity({
    required this.id,
    required this.companyId,
    required this.assetId,
    required this.locationId,
    required this.areaId,
    required this.assignedToId,
    required this.createdById,
    this.createdByProviderProfileId,
    required this.maintenancePlanId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.type,
    required this.scheduledDate,
    required this.startedAt,
    required this.completedAt,
    required this.estimatedDuration,
    required this.actualDuration,
    required this.laborCost,
    required this.partsCost,
    required this.totalCost,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
    this.attachments = const [],
    required this.serviceProviderCompanyId,
    required this.providerProfileId,
    this.openedBy = AppMode.internal,
    required this.slaPolicyId,
    required this.slaDeadlineAt,
    this.slaBreached = false,
    required this.netActiveDuration,
    required this.completionReason,
    required this.completionResponsibility,
    required this.completionSectorId,
    this.advanceWarningSentAt,
    this.lastEscalationLevel = 0,
    this.lastEscalationAt,
  });

  final String id;
  final String companyId;
  final String? assetId;
  final String locationId;
  final String? areaId;
  final String? assignedToId;

  /// Null when the work order was opened from provider mode — mutually
  /// exclusive with [createdByProviderProfileId].
  final String? createdById;

  /// Set when the work order was opened from provider mode.
  final String? createdByProviderProfileId;
  final String? maintenancePlanId;
  final String title;
  final String? description;
  final Priority priority;
  final WorkOrderStatus status;
  final WorkOrderType type;
  final DateTime? scheduledDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int? estimatedDuration;
  final int? actualDuration;
  final double? laborCost;
  final double? partsCost;
  final double? totalCost;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final List<AttachmentEntity> attachments;
  final String? serviceProviderCompanyId;
  final String? providerProfileId;
  final AppMode openedBy;
  final String? slaPolicyId;
  final DateTime? slaDeadlineAt;
  final bool slaBreached;
  final int? netActiveDuration;
  final String? completionReason;
  final PauseResponsibility? completionResponsibility;
  final String? completionSectorId;
  final DateTime? advanceWarningSentAt;
  final int lastEscalationLevel;
  final DateTime? lastEscalationAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    assetId,
    locationId,
    areaId,
    assignedToId,
    createdById,
    createdByProviderProfileId,
    maintenancePlanId,
    title,
    description,
    priority,
    status,
    type,
    scheduledDate,
    startedAt,
    completedAt,
    estimatedDuration,
    actualDuration,
    laborCost,
    partsCost,
    totalCost,
    notes,
    createdAt,
    updatedAt,
    deletedAt,
    attachments,
    serviceProviderCompanyId,
    providerProfileId,
    openedBy,
    slaPolicyId,
    slaDeadlineAt,
    slaBreached,
    netActiveDuration,
    completionReason,
    completionResponsibility,
    completionSectorId,
    advanceWarningSentAt,
    lastEscalationLevel,
    lastEscalationAt,
  ];

  WorkOrderEntity copyWith({
    String? id,
    String? companyId,
    String? assetId,
    String? locationId,
    String? areaId,
    String? assignedToId,
    String? createdById,
    String? createdByProviderProfileId,
    String? maintenancePlanId,
    String? title,
    String? description,
    Priority? priority,
    WorkOrderStatus? status,
    WorkOrderType? type,
    DateTime? scheduledDate,
    DateTime? startedAt,
    DateTime? completedAt,
    int? estimatedDuration,
    int? actualDuration,
    double? laborCost,
    double? partsCost,
    double? totalCost,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<AttachmentEntity>? attachments,
    String? serviceProviderCompanyId,
    String? providerProfileId,
    AppMode? openedBy,
    String? slaPolicyId,
    DateTime? slaDeadlineAt,
    bool? slaBreached,
    int? netActiveDuration,
    String? completionReason,
    PauseResponsibility? completionResponsibility,
    String? completionSectorId,
    DateTime? advanceWarningSentAt,
    int? lastEscalationLevel,
    DateTime? lastEscalationAt,
    bool? annulCreatedById,
    bool? annulCreatedByProviderProfileId,
    bool? annulAssetId,
    bool? annulAreaId,
    bool? annulAssignedToId,
    bool? annulMaintenancePlanId,
    bool? annulScheduledDate,
    bool? annulStartedAt,
    bool? annulCompletedAt,
    bool? annulEstimatedDuration,
    bool? annulActualDuration,
    bool? annulLaborCost,
    bool? annulPartsCost,
    bool? annulTotalCost,
    bool? annulNotes,
    bool? annulDeletedAt,
    bool? annulServiceProviderCompanyId,
    bool? annulProviderProfileId,
    bool? annulSlaPolicyId,
    bool? annulSlaDeadlineAt,
    bool? annulNetActiveDuration,
    bool? annulCompletionReason,
    bool? annulCompletionResponsibility,
    bool? annulCompletionSectorId,
    bool? annulAdvanceWarningSentAt,
    bool? annulLastEscalationAt,
  }) {
    return WorkOrderEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      assetId: annulAssetId == true ? null : assetId ?? this.assetId,
      locationId: locationId ?? this.locationId,
      areaId: annulAreaId == true ? null : areaId ?? this.areaId,
      assignedToId: annulAssignedToId == true
          ? null
          : assignedToId ?? this.assignedToId,
      createdById: annulCreatedById == true
          ? null
          : createdById ?? this.createdById,
      createdByProviderProfileId: annulCreatedByProviderProfileId == true
          ? null
          : createdByProviderProfileId ?? this.createdByProviderProfileId,
      maintenancePlanId: annulMaintenancePlanId == true
          ? null
          : maintenancePlanId ?? this.maintenancePlanId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      type: type ?? this.type,
      scheduledDate: annulScheduledDate == true
          ? null
          : scheduledDate ?? this.scheduledDate,
      startedAt: annulStartedAt == true ? null : startedAt ?? this.startedAt,
      completedAt: annulCompletedAt == true
          ? null
          : completedAt ?? this.completedAt,
      estimatedDuration: annulEstimatedDuration == true
          ? null
          : estimatedDuration ?? this.estimatedDuration,
      actualDuration: annulActualDuration == true
          ? null
          : actualDuration ?? this.actualDuration,
      laborCost: annulLaborCost == true ? null : laborCost ?? this.laborCost,
      partsCost: annulPartsCost == true ? null : partsCost ?? this.partsCost,
      totalCost: annulTotalCost == true ? null : totalCost ?? this.totalCost,
      notes: annulNotes == true ? null : notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
      attachments: attachments ?? this.attachments,
      serviceProviderCompanyId: annulServiceProviderCompanyId == true
          ? null
          : serviceProviderCompanyId ?? this.serviceProviderCompanyId,
      providerProfileId: annulProviderProfileId == true
          ? null
          : providerProfileId ?? this.providerProfileId,
      openedBy: openedBy ?? this.openedBy,
      slaPolicyId: annulSlaPolicyId == true
          ? null
          : slaPolicyId ?? this.slaPolicyId,
      slaDeadlineAt: annulSlaDeadlineAt == true
          ? null
          : slaDeadlineAt ?? this.slaDeadlineAt,
      slaBreached: slaBreached ?? this.slaBreached,
      netActiveDuration: annulNetActiveDuration == true
          ? null
          : netActiveDuration ?? this.netActiveDuration,
      completionReason: annulCompletionReason == true
          ? null
          : completionReason ?? this.completionReason,
      completionResponsibility: annulCompletionResponsibility == true
          ? null
          : completionResponsibility ?? this.completionResponsibility,
      completionSectorId: annulCompletionSectorId == true
          ? null
          : completionSectorId ?? this.completionSectorId,
      advanceWarningSentAt: annulAdvanceWarningSentAt == true
          ? null
          : advanceWarningSentAt ?? this.advanceWarningSentAt,
      lastEscalationLevel: lastEscalationLevel ?? this.lastEscalationLevel,
      lastEscalationAt: annulLastEscalationAt == true
          ? null
          : lastEscalationAt ?? this.lastEscalationAt,
    );
  }
}
