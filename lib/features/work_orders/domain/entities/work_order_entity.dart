import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/attachments/domain/entities/attachment_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_status.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/work_order_type.dart';

class WorkOrderEntity extends Equatable {
  const WorkOrderEntity({
    required this.id,
    required this.companyId,
    this.assetId,
    required this.locationId,
    this.assignedToId,
    required this.createdById,
    this.maintenancePlanId,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    required this.type,
    this.scheduledDate,
    this.startedAt,
    this.completedAt,
    this.estimatedDuration,
    this.actualDuration,
    this.laborCost,
    this.partsCost,
    this.totalCost,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.attachments = const [],
  });

  final String id;
  final String companyId;
  final String? assetId;
  final String locationId;
  final String? assignedToId;
  final String createdById;
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

  @override
  List<Object?> get props => [
    id,
    companyId,
    assetId,
    locationId,
    assignedToId,
    createdById,
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
  ];

  WorkOrderEntity copyWith({
    String? id,
    String? companyId,
    String? assetId,
    String? locationId,
    String? assignedToId,
    String? createdById,
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
    bool? annulAssetId,
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
  }) {
    return WorkOrderEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      assetId: annulAssetId == true ? null : assetId ?? this.assetId,
      locationId: locationId ?? this.locationId,
      assignedToId: annulAssignedToId == true
          ? null
          : assignedToId ?? this.assignedToId,
      createdById: createdById ?? this.createdById,
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
    );
  }
}
