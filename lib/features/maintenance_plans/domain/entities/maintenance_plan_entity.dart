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
  }) {
    return MaintenancePlanEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      assetId: assetId ?? this.assetId,
      locationId: locationId ?? this.locationId,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      monthOfYear: monthOfYear ?? this.monthOfYear,
      checklistTemplateId: checklistTemplateId ?? this.checklistTemplateId,
      assignedToId: assignedToId ?? this.assignedToId,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  MaintenancePlanEntity annulAssetId() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: null,
        locationId: locationId,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
        checklistTemplateId: checklistTemplateId,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulLocationId() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: null,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
        checklistTemplateId: checklistTemplateId,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulDescription() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
        title: title,
        description: null,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
        checklistTemplateId: checklistTemplateId,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulDayOfWeek() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: null,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
        checklistTemplateId: checklistTemplateId,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulDayOfMonth() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: null,
        monthOfYear: monthOfYear,
        checklistTemplateId: checklistTemplateId,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulMonthOfYear() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: null,
        checklistTemplateId: checklistTemplateId,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulChecklistTemplateId() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
        checklistTemplateId: null,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulAssignedToId() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
        checklistTemplateId: checklistTemplateId,
        assignedToId: null,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulLastGeneratedAt() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
        checklistTemplateId: checklistTemplateId,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: null,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulNextDueDate() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
        checklistTemplateId: checklistTemplateId,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: null,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  MaintenancePlanEntity annulDeletedAt() => MaintenancePlanEntity(
        id: id,
        companyId: companyId,
        assetId: assetId,
        locationId: locationId,
        title: title,
        description: description,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        monthOfYear: monthOfYear,
        checklistTemplateId: checklistTemplateId,
        assignedToId: assignedToId,
        priority: priority,
        isActive: isActive,
        lastGeneratedAt: lastGeneratedAt,
        nextDueDate: nextDueDate,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: null,
      );
}
