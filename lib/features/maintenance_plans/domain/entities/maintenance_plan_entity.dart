import 'package:clean_architecture/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:equatable/equatable.dart';

final class MaintenancePlanEntity extends Equatable {
  const MaintenancePlanEntity({
    required this.id,
    required this.companyId,
    this.assetId,
    this.locationId,
    required this.title,
    this.description,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    this.monthOfYear,
    this.checklistTemplateId,
    this.assignedToId,
    required this.priority,
    required this.isActive,
    this.lastGeneratedAt,
    this.nextDueDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String companyId;
  final String? assetId;
  final String? locationId;
  final String title;
  final String? description;
  final Frequency frequency;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final int? monthOfYear;
  final String? checklistTemplateId;
  final String? assignedToId;
  final Priority priority;
  final bool isActive;
  final DateTime? lastGeneratedAt;
  final DateTime? nextDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        companyId,
        assetId,
        locationId,
        title,
        description,
        frequency,
        dayOfWeek,
        dayOfMonth,
        monthOfYear,
        checklistTemplateId,
        assignedToId,
        priority,
        isActive,
        lastGeneratedAt,
        nextDueDate,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
