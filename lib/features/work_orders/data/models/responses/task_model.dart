import 'package:o_jogo_da_obra/core/data/models/data_convertible.dart';
import 'package:o_jogo_da_obra/core/utils/extensions/date_time_extension.dart';
import 'package:o_jogo_da_obra/core/utils/type_defs.dart';
import 'package:o_jogo_da_obra/features/work_orders/domain/entities/task_entity.dart';

class TaskModel extends TaskEntity
    implements
    DataConvertible<TaskEntity> {
  const TaskModel({
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

  factory TaskModel.fromEntity(TaskEntity entity) => TaskModel(
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

  factory TaskModel.fromJson(MapDynamic json) => TaskModel(
    id: json['id'] as String? ?? '',
    workOrderId: json['work_order_id'] as String? ?? '',
    companyId: json['company_id'] as String? ?? '',
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    isCompleted: json['is_completed'] as bool? ?? false,
    completedAt: (json['completed_at'] as String?).toUtcDateTime(),
    completedById: json['completed_by_id'] as String?,
    sortOrder: json['sort_order'] as int? ?? 0,
    createdAt: (json['created_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    updatedAt: (json['updated_at'] as String?).toUtcDateTime() ??
        DateTime.now().toUtc(),
    deletedAt: (json['deleted_at'] as String?).toUtcDateTime(),
  );

  @override
  MapDynamic toJson() => {
    'id': id,
    'work_order_id': workOrderId,
    'company_id': companyId,
    'title': title,
    'description': description,
    'is_completed': isCompleted,
    'completed_at': completedAt?.toIsoUtcString(),
    'completed_by_id': completedById,
    'sort_order': sortOrder,
    'created_at': createdAt.toIsoUtcString(),
    'updated_at': updatedAt.toIsoUtcString(),
    'deleted_at': deletedAt?.toIsoUtcString(),
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
