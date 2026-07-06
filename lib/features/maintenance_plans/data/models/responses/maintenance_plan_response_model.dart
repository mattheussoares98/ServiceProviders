import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/frequency.dart';
import 'package:o_jogo_da_obra/features/maintenance_plans/domain/entities/maintenance_plan_entity.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/priority.dart';

class MaintenancePlanResponseModel extends MaintenancePlanEntity
    implements DataConvertible<MaintenancePlanEntity> {
  const MaintenancePlanResponseModel({
    required super.id,
    required super.companyId,
    super.assetId,
    super.locationId,
    required super.title,
    super.description,
    required super.frequency,
    super.dayOfWeek,
    super.dayOfMonth,
    super.monthOfYear,
    super.checklistTemplateId,
    super.assignedToId,
    required super.priority,
    required super.isActive,
    super.lastGeneratedAt,
    super.nextDueDate,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory MaintenancePlanResponseModel.fromEntity(
    MaintenancePlanEntity entity,
  ) => MaintenancePlanResponseModel(
    id: entity.id,
    companyId: entity.companyId,
    assetId: entity.assetId,
    locationId: entity.locationId,
    title: entity.title,
    description: entity.description,
    frequency: entity.frequency,
    dayOfWeek: entity.dayOfWeek,
    dayOfMonth: entity.dayOfMonth,
    monthOfYear: entity.monthOfYear,
    checklistTemplateId: entity.checklistTemplateId,
    assignedToId: entity.assignedToId,
    priority: entity.priority,
    isActive: entity.isActive,
    lastGeneratedAt: entity.lastGeneratedAt,
    nextDueDate: entity.nextDueDate,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory MaintenancePlanResponseModel.fromJson(MapDynamic json) =>
      MaintenancePlanResponseModel(
        id: json['id'] as String? ?? '',
        companyId: json['company_id'] as String? ?? '',
        assetId: json['asset_id'] as String?,
        locationId: json['location_id'] as String?,
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        frequency: Frequency.fromCode(
          json['frequency'] as String? ?? 'monthly',
        ),
        dayOfWeek: json['day_of_week'] as int?,
        dayOfMonth: json['day_of_month'] as int?,
        monthOfYear: json['month_of_year'] as int?,
        checklistTemplateId: json['checklist_template_id'] as String?,
        assignedToId: json['assigned_to_id'] as String?,
        priority: Priority.fromCode(json['priority'] as String? ?? 'medium'),
        isActive: json['is_active'] as bool? ?? true,
        lastGeneratedAt: json['last_generated_at'] != null
            ? DateTime.parse(json['last_generated_at'] as String)
            : null,
        nextDueDate: json['next_due_date'] != null
            ? DateTime.parse(json['next_due_date'] as String)
            : null,
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
    'title': title,
    'description': description,
    'frequency': frequency.code,
    'day_of_week': dayOfWeek,
    'day_of_month': dayOfMonth,
    'month_of_year': monthOfYear,
    'checklist_template_id': checklistTemplateId,
    'assigned_to_id': assignedToId,
    'priority': priority.code,
    'is_active': isActive,
    'last_generated_at': lastGeneratedAt?.toIso8601String(),
    'next_due_date': nextDueDate?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };

  @override
  MaintenancePlanEntity toEntity() => MaintenancePlanEntity(
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
    deletedAt: deletedAt,
  );
}
