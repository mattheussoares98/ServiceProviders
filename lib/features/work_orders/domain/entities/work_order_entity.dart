import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_status.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/work_order_type.dart';
import 'package:equatable/equatable.dart';

final class WorkOrderEntity extends Equatable {
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
      ];
}
