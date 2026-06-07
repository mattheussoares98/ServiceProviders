import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.workOrderId,
    required this.companyId,
    required this.title,
    this.description,
    required this.isCompleted,
    this.completedAt,
    this.completedById,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String workOrderId;
  final String companyId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final String? completedById;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  @override
  List<Object?> get props => [
        id,
        workOrderId,
        companyId,
        title,
        description,
        isCompleted,
        completedAt,
        completedById,
        sortOrder,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  TaskEntity copyWith({
    String? id,
    String? workOrderId,
    String? companyId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    String? completedById,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      completedById: completedById ?? this.completedById,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  TaskEntity annulDescription() => TaskEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        title: title,
        description: null,
        isCompleted: isCompleted,
        completedAt: completedAt,
        completedById: completedById,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  TaskEntity annulCompletedAt() => TaskEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        title: title,
        description: description,
        isCompleted: isCompleted,
        completedAt: null,
        completedById: completedById,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  TaskEntity annulCompletedById() => TaskEntity(
        id: id,
        workOrderId: workOrderId,
        companyId: companyId,
        title: title,
        description: description,
        isCompleted: isCompleted,
        completedAt: completedAt,
        completedById: null,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
      );

  TaskEntity annulDeletedAt() => TaskEntity(
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
        deletedAt: null,
      );
}
