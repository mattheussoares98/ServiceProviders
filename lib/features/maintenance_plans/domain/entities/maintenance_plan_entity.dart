import 'package:equatable/equatable.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/interval_unit.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';

class MaintenancePlanEntity extends Equatable {
  const MaintenancePlanEntity({
    required this.id,
    required this.companyId,
    required this.locationId,
    required this.assetId,
    required this.areaId,
    required this.assignedToId,
    required this.serviceProviderCompanyId,
    required this.checklistTemplateId,
    required this.title,
    required this.description,
    required this.priority,
    required this.price,
    required this.currency,
    required this.intervalValue,
    required this.intervalUnit,
    required this.leadTimeDays,
    required this.durationDays,
    required this.dayOfWeek,
    required this.dayOfMonth,
    required this.monthOfYear,
    required this.isActive,
    required this.lastGeneratedAt,
    required this.lastGeneratedWorkOrderId,
    required this.lastError,
    required this.nextDueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  final String id;
  final String companyId;
  final String? locationId;
  final String? assetId;
  final String? areaId;
  final String? assignedToId;
  final String? serviceProviderCompanyId;
  final String? checklistTemplateId;
  final String title;
  final String? description;
  final Priority priority;
  final double? price;
  final String currency;
  final int intervalValue;
  final IntervalUnit intervalUnit;
  final int leadTimeDays;
  final int durationDays;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final int? monthOfYear;
  final bool isActive;
  final DateTime? lastGeneratedAt;
  final String? lastGeneratedWorkOrderId;
  final String? lastError;
  final DateTime? nextDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
    id,
    companyId,
    locationId,
    assetId,
    areaId,
    assignedToId,
    serviceProviderCompanyId,
    checklistTemplateId,
    title,
    description,
    priority,
    price,
    currency,
    intervalValue,
    intervalUnit,
    leadTimeDays,
    durationDays,
    dayOfWeek,
    dayOfMonth,
    monthOfYear,
    isActive,
    lastGeneratedAt,
    lastGeneratedWorkOrderId,
    lastError,
    nextDueDate,
    createdAt,
    updatedAt,
    deletedAt,
  ];

  MaintenancePlanEntity copyWith({
    String? id,
    String? companyId,
    String? locationId,
    String? assetId,
    String? areaId,
    String? assignedToId,
    String? serviceProviderCompanyId,
    String? checklistTemplateId,
    String? title,
    String? description,
    Priority? priority,
    double? price,
    String? currency,
    int? intervalValue,
    IntervalUnit? intervalUnit,
    int? leadTimeDays,
    int? durationDays,
    int? dayOfWeek,
    int? dayOfMonth,
    int? monthOfYear,
    bool? isActive,
    DateTime? lastGeneratedAt,
    String? lastGeneratedWorkOrderId,
    String? lastError,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? annulLocationId,
    bool? annulAssetId,
    bool? annulAreaId,
    bool? annulAssignedToId,
    bool? annulServiceProviderCompanyId,
    bool? annulChecklistTemplateId,
    bool? annulDescription,
    bool? annulPrice,
    bool? annulDayOfWeek,
    bool? annulDayOfMonth,
    bool? annulMonthOfYear,
    bool? annulLastGeneratedAt,
    bool? annulLastGeneratedWorkOrderId,
    bool? annulLastError,
    bool? annulNextDueDate,
    bool? annulDeletedAt,
  }) {
    return MaintenancePlanEntity(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      locationId: annulLocationId == true ? null : locationId ?? this.locationId,
      assetId: annulAssetId == true ? null : assetId ?? this.assetId,
      areaId: annulAreaId == true ? null : areaId ?? this.areaId,
      assignedToId: annulAssignedToId == true ? null : assignedToId ?? this.assignedToId,
      serviceProviderCompanyId: annulServiceProviderCompanyId == true
          ? null
          : serviceProviderCompanyId ?? this.serviceProviderCompanyId,
      checklistTemplateId: annulChecklistTemplateId == true
          ? null
          : checklistTemplateId ?? this.checklistTemplateId,
      title: title ?? this.title,
      description: annulDescription == true ? null : description ?? this.description,
      priority: priority ?? this.priority,
      price: annulPrice == true ? null : price ?? this.price,
      currency: currency ?? this.currency,
      intervalValue: intervalValue ?? this.intervalValue,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      leadTimeDays: leadTimeDays ?? this.leadTimeDays,
      durationDays: durationDays ?? this.durationDays,
      dayOfWeek: annulDayOfWeek == true ? null : dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: annulDayOfMonth == true ? null : dayOfMonth ?? this.dayOfMonth,
      monthOfYear: annulMonthOfYear == true ? null : monthOfYear ?? this.monthOfYear,
      isActive: isActive ?? this.isActive,
      lastGeneratedAt: annulLastGeneratedAt == true
          ? null
          : lastGeneratedAt ?? this.lastGeneratedAt,
      lastGeneratedWorkOrderId: annulLastGeneratedWorkOrderId == true
          ? null
          : lastGeneratedWorkOrderId ?? this.lastGeneratedWorkOrderId,
      lastError: annulLastError == true ? null : lastError ?? this.lastError,
      nextDueDate: annulNextDueDate == true ? null : nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
