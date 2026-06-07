import 'package:clean_architecture/core/data/models/data_convertible.dart';
import 'package:clean_architecture/core/utils/type_defs.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_entity.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_type.dart';

class WorkOrderRequestModel extends WorkOrderEntity
    implements DataConvertible<WorkOrderEntity> {
  const WorkOrderRequestModel({
    required super.id,
    required super.companyId,
    super.assetId,
    required super.locationId,
    super.assignedToId,
    required super.createdById,
    super.maintenancePlanId,
    required super.title,
    super.description,
    required super.priority,
    required super.status,
    required super.type,
    super.scheduledDate,
    super.startedAt,
    super.completedAt,
    super.estimatedDuration,
    super.actualDuration,
    super.laborCost,
    super.partsCost,
    super.totalCost,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory WorkOrderRequestModel.fromEntity(WorkOrderEntity entity) =>
      WorkOrderRequestModel(
        id: entity.id,
        companyId: entity.companyId,
        assetId: entity.assetId,
        locationId: entity.locationId,
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
      );

  factory WorkOrderRequestModel.fromJson(MapDynamic json) =>
      WorkOrderRequestModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        assetId: json['asset_id'] as String?,
        locationId: json['location_id'] as String? ?? '',
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
      );

  @override
  MapDynamic toJson() => {
        'id': id,
        'company_id': companyId,
        'asset_id': assetId,
        'location_id': locationId,
        'assigned_to_id': assignedToId,
        'created_by_id': createdById,
        'maintenance_plan_id': maintenancePlanId,
        'title': title,
        'description': description,
        'priority': priority.code,
        'status': status.code,
        'type': type.code,
        'scheduled_date': scheduledDate?.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'estimated_duration': estimatedDuration,
        'actual_duration': actualDuration,
        'labor_cost': laborCost,
        'parts_cost': partsCost,
        'total_cost': totalCost,
        'notes': notes,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };

  @override
  WorkOrderEntity toEntity() => WorkOrderEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
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
      );
}
