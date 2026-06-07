import 'package:clean_architecture/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:clean_architecture/features/work_orders/domain/entities/priority.dart';
import 'package:equatable/equatable.dart';

class MaintenancePlanEntity extends Equatable {
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

  MaintenancePlanEntity copyWith({
    String? id,
    String? companyId,
    String? assetId,
    String? locationId,
    String? title,
    String? description,
    Frequency? frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    int? monthOfYear,
    String? checklistTemplateId,
    String? assignedToId,
    Priority? priority,
    bool? isActive,
    DateTime? lastGeneratedAt,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulAssetId,
    bool? annulLocationId,
    bool? annulDescription,
    bool? annulDayOfWeek,
    bool? annulDayOfMonth,
    bool? annulMonthOfYear,
    bool? annulChecklistTemplateId,
    bool? annulAssignedToId,
    bool? annulLastGeneratedAt,
    bool? annulNextDueDate,
    bool? annulDeletedAt,
  }) {
    return MaintenancePlanEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      assetId: annulAssetId == true ? null : assetId ?? this.assetId,
      locationId: annulLocationId == true
          ? null
          : locationId ?? this.locationId,
      title: title ?? this.title,
      description: annulDescription == true
          ? null
          : description ?? this.description,
      frequency: frequency ?? this.frequency,
      dayOfWeek: annulDayOfWeek == true ? null : dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: annulDayOfMonth == true
          ? null
          : dayOfMonth ?? this.dayOfMonth,
      monthOfYear: annulMonthOfYear == true
          ? null
          : monthOfYear ?? this.monthOfYear,
      checklistTemplateId: annulChecklistTemplateId == true
          ? null
          : checklistTemplateId ?? this.checklistTemplateId,
      assignedToId: annulAssignedToId == true
          ? null
          : assignedToId ?? this.assignedToId,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      lastGeneratedAt: annulLastGeneratedAt == true
          ? null
          : lastGeneratedAt ?? this.lastGeneratedAt,
      nextDueDate: annulNextDueDate == true
          ? null
          : nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
