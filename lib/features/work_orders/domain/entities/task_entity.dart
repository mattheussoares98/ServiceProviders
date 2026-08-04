import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  const TaskEntity({
    required this.id,
    required this.workOrderId,
    required this.companyId,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.completedAt,
    required this.completedById,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
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
    bool? annulDescription,
    bool? annulCompletedAt,
    bool? annulCompletedById,
    bool? annulDeletedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      workOrderId: workOrderId ?? this.workOrderId,
      companyId: companyId ?? this.companyId,
      title: title ?? this.title,
      description: annulDescription == true
          ? null
          : description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: annulCompletedAt == true
          ? null
          : completedAt ?? this.completedAt,
      completedById: annulCompletedById == true
          ? null
          : completedById ?? this.completedById,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: annulDeletedAt == true ? null : deletedAt ?? this.deletedAt,
    );
  }
}
