import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/task_entity.dart';

class TaskRequestModel extends TaskEntity
    implements DataConvertible<TaskEntity> {
  const TaskRequestModel({
    required super.id,
    required super.workOrderId,
    required super.companyId,
    required super.title,
    super.description,
    required super.isCompleted,
    super.completedAt,
    super.completedById,
    required super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory TaskRequestModel.fromEntity(TaskEntity entity) => TaskRequestModel(
    id: entity.id,
    workOrderId: entity.workOrderId,
    companyId: entity.companyId,
    title: entity.title,
    description: entity.description,
    isCompleted: entity.isCompleted,
    completedAt: entity.completedAt,
    completedById: entity.completedById,
    sortOrder: entity.sortOrder,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    deletedAt: entity.deletedAt,
  );

  factory TaskRequestModel.fromJson(MapDynamic json) => TaskRequestModel(
    id: json['id'] as String? ?? '',
    workOrderId: json['work_order_id'] as String? ?? '',
    companyId: json['company_id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    isCompleted: json['is_completed'] as bool? ?? false,
    completedAt: json['completed_at'] != null
        ? DateTime.parse(json['completed_at'] as String)
        : null,
    completedById: json['completed_by_id'] as String?,
    sortOrder: json['sort_order'] as int? ?? 0,
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
    'work_order_id': workOrderId,
    'company_id': companyId,
    'title': title,
    'description': description,
    'is_completed': isCompleted,
    'completed_at': completedAt?.toIso8601String(),
    'completed_by_id': completedById,
    'sort_order': sortOrder,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
  };

  @override
  TaskEntity toEntity() => TaskEntity(
    id: id,
    workOrderId: workOrderId,
    companyId: companyId,
    title: title,
    description: description,
    isCompleted: isCompleted,
    completedAt: completedAt,
    completedById: completedById,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
  );
}
